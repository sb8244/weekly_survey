defmodule WeeklySurvey.Surveys do
  alias WeeklySurvey.Surveys.Survey
  alias WeeklySurvey.Surveys.Answer

  def add_answer_to_survey(survey_id, answer) do
    {:ok, true}
  end

  def get_available_surveys() do
    [
      %Survey{
        id: 1,
        name: "Weekly Star",
        question: "Who should be the star this week?",
        answers: [
          %Answer{
            id: 1,
            answer: "Test McTesterson",
            votes: 10,
            discussions: [
              "So team over self!",
              "Wrote a great TPS report"
            ],
          },
          %Answer{
            id: 2,
            answer: "Johnny McMaste",
            votes: 1,
            discussions: []
          }
        ]
      },
      %Survey{
        id: 2,
        name: "Monthly Struggle",
        question: "What is a struggle that needs fixed?",
        answers: []
      },
    ]
  end
end
