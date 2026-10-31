if (!requireNamespace("shiny", quietly = TRUE)) stop("Install 'shiny' to use this app.")

ui <- shiny::fluidPage(
  shiny::titlePanel("Hedonic Value 2026 — fluxo auditável"),
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::fileInput("file", "Planilha CSV/XLS/XLSX", accept = c(".csv", ".xls", ".xlsx")),
      shiny::uiOutput("sheet_ui"), shiny::uiOutput("y_ui"),
      shiny::actionButton("validate", "Validar dados"),
      shiny::actionButton("optimize", "Otimizar famílias A/B"),
      shiny::helpText("A classificação normativa permanece pendente de edição, evidência e julgamento do perito.")
    ),
    shiny::mainPanel(
      shiny::tabsetPanel(
        shiny::tabPanel("Prévia", shiny::tableOutput("preview"), shiny::verbatimTextOutput("validation")),
        shiny::tabPanel("Comparação", shiny::tableOutput("comparison")),
        shiny::tabPanel("Normativo", shiny::tableOutput("normative"))
      )
    )
  )
)

server <- function(input, output, session) {
  imported <- shiny::reactive({
    shiny::req(input$file)
    hv_import_data(input$file$datapath, sheet = if (is.null(input$sheet)) 1 else input$sheet)
  })
  output$sheet_ui <- shiny::renderUI({
    shiny::req(input$file)
    if (tolower(tools::file_ext(input$file$name)) %in% c("xls", "xlsx"))
      shiny::numericInput("sheet", "Planilha", 1, min = 1, step = 1)
  })
  output$y_ui <- shiny::renderUI({
    d <- imported(); shiny::selectInput("y", "Variável dependente Y", names(d))
  })
  output$preview <- shiny::renderTable({ utils::head(imported(), 10) })
  checked <- shiny::eventReactive(input$validate, {
    shiny::req(input$y); hv_validate_data(imported(), input$y,
      predictors = setdiff(names(imported()), input$y), missing = "complete_cases")
  })
  output$validation <- shiny::renderPrint({ shiny::req(checked()); checked() })
  optimized <- shiny::eventReactive(input$optimize, {
    shiny::req(input$y)
    predictors <- setdiff(names(imported()), input$y)
    hv_optimize_hedonic(imported(), input$y, predictors = predictors,
      categorical = predictors[vapply(imported()[predictors], function(x)
        is.character(x) || is.factor(x) || is.logical(x), logical(1))],
      population_size = 12, generations = 10, patience = 4, exhaustive_limit = 256)
  })
  output$comparison <- shiny::renderTable({ shiny::req(optimized()); optimized()$comparison })
  output$normative <- shiny::renderTable({
    x <- optimized(); shiny::req(x, !is.na(x$recommended_family))
    mod <- x$selected_models[[x$recommended_family]]
    hv_normative_checks(mod$model, imported(), input$y, normative_source = NULL)
  })
}

shiny::shinyApp(ui, server)
