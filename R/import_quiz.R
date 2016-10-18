import_quiz <- function(data,
                       html_patterns = c("<div>", "</div>", "<p>", "</p>")
                       ){
  ## questions
  # data$assessment$section$item$presentation$material$mattext$text
  ## answer
  # data$assessment$section$item$presentation$response_lid$render_choice$response_label$material$mattext$text

  questions <- list()
  all_answers <- list()
  for (i in 1:length(data$assessment$section)) {
    ## For each question, get the question text:
    item <- data$assessment$section[[i]]
    if (class(item) != "character"){
      questions[i] <- item$presentation$material$mattext$text
      answers <- list()
      for (j in 1:length(item$presentation$response_lid$render_choice)) {
        ## For all answers, get the answer text
        response_label <- item$presentation$response_lid$render_choice[[j]]
        if (class(response_label$material$mattext) != "character"){
          answers[j] <- response_label$material$mattext$text
        }
        if (j == length(item$presentation$response_lid$render_choice)) {
          ## Put the answers in a list
          all_answers[[i]] <- unlist(answers)
        }
      }
    }
  }

  # in case not all questions have the same number of possible answers
  max_answers <- 0
  for (k in 1:length(all_answers)){
    if (length(all_answers[[k]] > max_answers)){
      max_answers <- length(all_answers[[k]])
    }
  }
  for (l in 1:length(all_answers)){
    if (length(all_answers[[l]] < max_answers)){
      all_answers[[l]] <- c(all_answers[[l]],
                           rep("", max_answers - length(all_answers[[l]])))
    }
    if (is.null(all_answers[[l]])){
      all_answers[[l]] <- rep("", max_answers)
    }
  }

  output <- data.frame(matrix(unlist(all_answers),
                             nrow = length(all_answers), byrow = TRUE))
  output$question <- unlist(questions)

  # take care of html from questions or answers
  for (m in 1:length(html_patterns)){
    output <- as.data.frame(apply(output, c(1, 2),
                                 function(x) gsub(html_patterns[m], "", x)))
  }
  return(output)
}