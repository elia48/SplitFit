class TrainingAiParserService
  def initialize(prompt)
    @prompt = prompt.to_s
  end

  def call
    response = RubyLLM.chat
      .with_model("gpt-4o-mini")
      .ask(instructions)

    JSON.parse(response.content)
  end

  private

  attr_reader :prompt

  def instructions
    <<~PROMPT
      You are an assistant for a Rails fitness app called SplitFit.

      Your task is to extract structured data from a coach request for creating a training session.

      Return ONLY valid JSON.
      Do not include markdown.
      Do not include explanations.

      Required JSON keys:
      {
        "workout_type": string,
        "place": string,
        "date": string,
        "duration": integer,
        "description": string,
        "price": number,
        "min_people": integer,
        "max_people": integer
      }

      Rules:
      - workout_type should be short, for example: HIIT, Yoga, Pilates, Strength, CrossFit, Running, Mobility.
      - place should be the location mentioned by the coach.
      - date must be ISO-like format if possible.
      - duration must be in minutes.
      - price is the total coach price per session in euros.
      - min_people and max_people must be integers.
      - description should be clear, commercial, and organized.
      - If a value is missing, use null.
      - If max_people is lower than min_people, keep the values as given. Do not silently fix them.

      Coach request:
      "#{prompt}"
    PROMPT
  end
end
