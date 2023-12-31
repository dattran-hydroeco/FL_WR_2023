# library("rstudioapi")
# setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) 

# library(tidyverse)
library("readxl")
library("data.table")
library(openxlsx)
library("reshape2")
library(showtext)
library(shiny)
library(dplyr)
library(ggplot2)
library(knitr)


# Use a fluid Bootstrap layout
ui <- fluidPage(
    # fileInput('file1', 'Show Water Use Data',
    #           accept = c('.xlsx')
    #           ),
    
    ## Give the page a title
    titlePanel(h3("Water Use Projection (in million gallon per day [mgd])")),
    
    ## Generate a row with a sidebar
    sidebarLayout(      
        
        ## Define the sidebar with one input
        sidebarPanel(
            selectInput("Cat", "Select Water Use Categrogy", 
                        #choices=colnames(FL_wateruse2023)[-1] ),
            choices=c("PS","DSS","AG","LR","CII","PG", "Total") ),
            
            downloadButton("downloadData1", "Download"),
            
            # selectInput("WaterTable", "Show Water Use Projection in Table",
            #             choices=c("Yes","No") ),
            
            # selectInput("Expen", "Show Expenditure", 
            #             choices=c("By Project Type","Total") ),
            
            # downloadButton("downloadData2", "Download"),
            
            hr("Source:  Data from Florida Department of Environmental Protection"),
            helpText("PS = Public Supply"),
            helpText("DSS = Domestic Self Supply"),
            helpText("AG = Agriculture"),
            helpText("LR = Landscape & Recreational"),
            helpText("CII = Commercial/Industrial/Institutional"),
            helpText("PG = Power Generation"),
            helpText("Unit: million gallon per day (mgd)")
        ),
        
        ## Create a spot for the barplot
        mainPanel(
            plotOutput("waterusePlot"),
            tableOutput('wateruseTable')

        )
        
    )
)




## Define a server for the Shiny app
server <- function(input, output) {
    
    ## Water Use data
    # FL_wateruse2023 <- read_excel("FL_water_demand_2023Report.xlsx", sheet = 1, col_names = TRUE)
    # FL_wateruse2023 <- data.frame(FL_wateruse2023)
    PS <- c(2368.574, 2590.553, 2768.085, 2917.864, 3052.453, 3181.454)
    DSS <- c(232.2403, 249.9549, 269.4988, 286.0526, 301.3125, 316.8192)
    AG <- c(2431.679, 2452.643, 2455.590, 2465.505, 2479.168, 2492.438)
    LR <- c(515.254, 556.494, 588.816, 619.055, 646.892, 673.971)
    CII <- c(409.349, 445.779, 461.339, 476.682, 484.070, 491.828)
    PG <- c(127.756, 141.307, 143.770, 160.472, 177.862, 179.828)
    Year <- c(2015, 2020, 2025, 2030, 2035, 2040)
    FL_wateruse2023 <- data.frame(Year= round(Year,0), PS=round(PS,0), DSS=round(DSS,0), 
                                  AG=round(AG,0), LR=round(LR,0), CII=round(CII,0), PG=round(PG, 0))
    
    FL_wateruse2023 <- reshape2::melt(FL_wateruse2023,id.vars=c("Year"), variable.names=c("water_use", "caterogy") )
    names(FL_wateruse2023) <- c("Year", "Caterogy", "water_use")
    
    # FL_wateruse2023 <- FL_wateruse2023 %>%
    #     group_by(Year) %>%
    #     mutate(y_label = cumsum(water_use) - 0.5*water_use)
    
    ## Data for table
    FL_wateruse2023v1 <- data.frame(Year= as.character(Year), PS=round(PS,2), DSS=round(DSS,2), 
                                  AG=round(AG,2), LR=round(LR,2), CII=round(CII,1), PG=round(PG, 2))
    
    ## Expenditure data
    


     
    ## create a data frame for plotting
    df <- reactive({
        req(input$Cat)
        # req(input$WaterTable)
        # req(input$Expen)
        
        if(input$Cat != "Total") {
            FL_wateruse2023 <- FL_wateruse2023 %>% filter(Caterogy %in% c(as.character(input$Cat)) ) 
            
        } else {
            FL_wateruse2023 <- FL_wateruse2023
        }
        
    })
    

    ## Fill in the spot we created for a plot
    output$waterusePlot <- renderPlot({
        
        ## Render a barplot
        
        germany_color <- "#e4a52a"
        greece_color <- "#206e73"
        nether_color <- "#02a4db" 
        spain_color <- "#e55743" 
        others_color <- "#80a6b1"
        red_icon <- "#ed1c24"
        bgr_color <- "#d9e9f0"
        pg_color <- "#20a6b1"
        # Load font for ploting: 
        my_font <- "Roboto Condensed" 
        
        
        ggplot(df(),(aes(x=as.factor(Year), y=water_use, fill=factor(Caterogy, levels = c("PG", "DSS", "CII", "LR", "PS", "AG")) ))) +
            geom_col() +
            xlab("Year") + ylab("Water use (mgd)") +
            theme_minimal() + theme(legend.title = element_blank()) + 
            scale_fill_manual(values = c(PS = germany_color, 
                                         DSS = greece_color, 
                                         AG = nether_color, 
                                         LR = spain_color, 
                                         CII = others_color,
                                         PG = pg_color)) + 
            theme(legend.position = "top") + 
            ### Make The Economist Theme: 
            theme(plot.background = element_rect(fill = bgr_color, color = NA)) + 
            theme(panel.background = element_rect(fill = bgr_color, color = NA)) +
            theme(legend.title = element_blank()) + 
            theme(legend.text = element_text(size = 16, color = "grey30", family = my_font)) + 
            theme(legend.key.height = unit(0.4, "cm")) + 
            theme(legend.key.width = unit(0.4, "cm")) + 
            theme(legend.background = element_rect(fill = bgr_color, colour = NA)) + 
            ### Adjust strip panel: 
            theme(strip.background = element_rect(fill = bgr_color)) + 
            theme(strip.text = element_text(color = "grey20", 
                                            family = my_font, hjust = -0.04, size = 16, face = "bold")) +
            ### Adjust axis
            labs(x="Year", y="Water Use (mgd)") + 
            theme(panel.grid.minor = element_blank()) + 
            theme(panel.grid.major.x = element_blank()) + 
            theme(axis.text.x = element_text(family = my_font, size = 16, color = "grey30")) + 
            theme(axis.text.y = element_text(family = my_font, size = 16, color = "grey30")) + 
            theme(legend.justification = "left") + 
            theme(axis.title.x = element_text(family = my_font, size = 16, color = "grey30")) + 
            theme(axis.title.y = element_text(family = my_font, size = 16, color = "grey30")) +
            theme(panel.grid = element_line(color = "white", size = 0.75)) + 
            guides(color = guide_legend(nrow = 1))
            # geom_text(aes(label = round(water_use,0), y = y_label), size=5, color = "grey30", family = my_font)


        
    })
    
    # output$wateruseTable <- renderTable(FL_wateruse2023v1)
    
    
    # Downloadable csv of selected water use (by caterogy) dataset
    output$downloadData1 <- downloadHandler(
        filename = function() {
            paste(input$df, ".csv", sep = "")
        },
        content = function(file) {
            write.csv(df(), file, row.names = FALSE)
        }
    )
        
}

shinyApp(ui = ui, server = server)


