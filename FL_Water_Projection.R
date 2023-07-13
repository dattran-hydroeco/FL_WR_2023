library("rstudioapi")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) 

library(tidyverse)
library("readxl")
library("data.table")
library(openxlsx)
library("reshape2")
library(showtext)


# Use a fluid Bootstrap layout
fluidPage(
    # fileInput('file1', 'Show Water Use Data',
    #           accept = c('.xlsx')
    #           ),
    
    # Give the page a title
    titlePanel(h3("Water Use Projection (in million gallon per day [mgd])")),
    
    # Generate a row with a sidebar
    sidebarLayout(      
        
        # Define the sidebar with one input
        sidebarPanel(
            selectInput("Cat", "Water Use Categrogy:", 
                        #choices=colnames(FL_wateruse2023)[-1] ),
            choices=c("PS","DSS","AG","LR","CII","PG", "All") ),
                        
            hr("Source:  Data from Florida Department of Environmental Protection"),
            helpText("PS = Public Supply"),
            helpText("DSS = Domestic Self Supply"),
            helpText("AG = Agriculture"),
            helpText("LR = Landscape & Recreational"),
            helpText("CII = Commercial/Industrial/Institutional"),
            helpText("PG = Power Generation"),
            helpText("Unit: million gallon per day (mgd)")
        ),
        
        # Create a spot for the barplot
        mainPanel(
            tableOutput('contents'),
            plotOutput("waterusePlot")

        )
        
    )
)




# Define a server for the Shiny app
function(input, output) {
    
    #read the data
    FL_wateruse2023 <- read_excel("FL_water_demand_2023Report.xlsx", sheet = 1, col_names = TRUE)
    FL_wateruse2023 <- data.frame(FL_wateruse2023)
    
    # create a data frame for plotting
    
    df <- reactive({
        req(input$Cat)
        
        #FL_wateruse2023 <- FL_wateruse2023 %>% select(Year=Year, Value=input$Cat)
        FL_wateruse2023 <- reshape2::melt(FL_wateruse2023,id.vars=c("Year"), variable.names=c("water_use", "caterogy") )
        names(FL_wateruse2023) <- c("Year", "Caterogy", "water_use")        
        
        if(input$Cat != "All") {
            FL_wateruse2023 <- FL_wateruse2023 %>% filter(Caterogy %in% c(as.character(input$Cat)))           
        } else {
            FL_wateruse2023 <- FL_wateruse2023
        }
        
        
        
    })
    
    
    # Fill in the spot we created for a plot
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
            theme(panel.grid.minor = element_blank()) + 
            theme(panel.grid.major.x = element_blank()) + 
            theme(axis.text.x = element_text(family = my_font, size = 16, color = "grey30")) + 
            theme(axis.text.y = element_text(family = my_font, size = 16, color = "grey30")) + 
            theme(legend.justification = "left") + 
            theme(axis.title.x = element_text(family = my_font, size = 16, color = "grey30")) + 
            theme(axis.title.y = element_text(family = my_font, size = 16, color = "grey30")) +
            theme(panel.grid = element_line(color = "white", size = 0.75))
        
        
        
    })
    
}

runApp()
