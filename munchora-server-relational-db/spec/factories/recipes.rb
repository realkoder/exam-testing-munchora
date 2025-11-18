FactoryBot.define do
  factory :recipe do
    association :user

    title { "Ande Burger 🍔" }
    image_url { "https://munchora.pro/uploads/recipes/f6aea855-cc8a-4d51-9245-5961fca2f3a2_image.jpg" }
    description {
      "Saftige andebryster, perfekt til en gourmetburger med frisk spidskål 🥗, " \
        "sprøde smagsnødder, og en lækker chilisauce. En luksuriøs twist på den klassiske burger! 😋"
    }
    instructions {
      [
        "På andebrystets bagside skæres alle sener og overskydende fedt væk. Rids derefter skindet i tern, uden at skære ned i kødet💥.",
        "Krydr andebrystet godt med salt og peber på begge sider 🎯.",
        "Varm en pande op på medium varme 🥘.",
        "Læg andebrystet på en kold pande med skindsiden nedad, og tænd for varmen. Steg i 5-7 minutter, indtil skindet er sprødt og gyldent 🔥.",
        "Vend andebrystet, og steg kødsiden i 1-2 minutter. Kontroller kernetemperaturen; den bør være minimum 60°C for medium 🥩.",
        "Lad kødet hvile utildækket i 10 minutter 🔄.",
        "Snit spidskålen fint, tilsæt en tsk honning, 2 spsk crème fraiche, og rør rundt 🥗.",
        "Rist burgerbollerne let, og smør et lag af spidskålssalaten på bunden. Skær andebrystet i fine skiver, og anret ovenpå salaten.",
        "Tilføj et drys koriander og sesamfrø for ekstra smag 🥜.",
        "Læg toppen af burgeren på, smør med chilimayo, og server straks - enjoy! 🍟"
      ]
    }
    is_public { true }
    cuisine { "Danish Gourmet 🇩🇰" }
    difficulty { "medium" }

    tags {
      ["andebryst", "burger", "gourmet", "salat", "let at lave", "fusion"]
    }
    prep_time { 15 }
    cook_time { 20 }
    servings { 2 }

    after(:build) do |recipe|
      recipe.ingredients << build_list(:ingredient, 3, recipe: recipe)
    end
  end
end
