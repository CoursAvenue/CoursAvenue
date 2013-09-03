# encoding: utf-8
class AddMissingSubjects < ActiveRecord::Migration
  def up
    s = Subject.where{name == 'Théâtre'}.first
    s.children.create(name: 'Art dramatique')
    s = Subject.where{name == 'Danse'}.first
    s.children.where{name == 'Danses du monde'}.first_or_create.children.create(name: "Coupé décalé, Kuduro & N'dombolo")
    s = Subject.where{name == 'Danse'}.first
    s.children.where{name == 'Danses du monde'}.first_or_create.children.create(name: "Danse des 5 rythmes, Biodanza & Danse thérapie")
    s = Subject.where{name == 'Danse'}.first
    s.children.where{name == 'Danses de couple'}.first_or_create.children.create(name: "Danses de couple")
    s = Subject.where{name == 'Danse'}.first
    s.children.where{name == 'Ecoles de danses'}.first_or_create.children.create(name: "Ecoles, centres & académies de danse")
    s = Subject.where{name == 'Danse'}.first
    s.children.where{name == 'Jazz & Modern jazz'}.first_or_create.children.create(name: "Jazz, Street Jazz & Modern jazz")
    s = Subject.where{name == 'Danse'}.first
    s.children.where{name == 'Danses urbaines'}.first_or_create.children.create(name: "Ragga, Dancehall & House")
    s = Subject.where{name == 'Danse'}.first
    s.children.where{name == 'Danses du monde'}.first_or_create.children.create(name: "Rumba, Paso doble & Jiive")
    s = Subject.where{name == 'Danse'}.first
    s.children.where{name == 'Danses du monde'}.first_or_create.children.create(name: "Salsa, Bachata & Chacha")
    s = Subject.where{name == 'Danse'}.first
    s.children.where{name == 'Danses urbaines'}.first_or_create.children.create(name: "Street, break & lock")
    s = Subject.where{name == 'Danse'}.first
    s.children.where{name == 'Rock & danses de salon'}.first_or_create.children.create(name: "Swing, Lindy hop & Be-bop")
    s = Subject.where{name == 'Danse'}.first
    s.children.where{name == 'Rock & danses de salon'}.first_or_create.children.create(name: "Valse, Slow fox & Quick step")
    s = Subject.where{name == 'Danse'}.first
    s.children.where{name == 'Danses du monde'}.first_or_create.children.create(name: "Zouk, Lambazouk & Merengue")

    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Chant'}.first_or_create.children.create(name: "Chant & instrument")
    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Chant'}.first_or_create.children.create(name: "Chant choral")
    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Chant'}.first_or_create.children.create(name: "Chant et randonnée")
    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Chant'}.first_or_create.children.create(name: "Chant lyrique & classique")
    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Chant'}.first_or_create.children.create(name: "Chant médiéval & grégorien")
    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Chant'}.first_or_create.children.create(name: "Chant sacré")
    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Chant'}.first_or_create.children.create(name: "Chants traditionnels & chants du monde")
    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Chant'}.first_or_create.children.create(name: "Comédies musicales")
    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Chant'}.first_or_create.children.create(name: "Jazz & gospel")
    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Musique & Instruments'}.first_or_create.children.create(name: " Culture musicale")
    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Ecoles de musique'}.first_or_create.children.create(name: "Ecoles, centres & académies de musique")
    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Musique par instrument'}.first_or_create.children.create(name: "Ensembles instrumentaux")
    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Lutherie'}.first_or_create.children.create(name: "Lutherie, fabrication & réparation d'instruments")
    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Musiques actuelles'}.first_or_create.children.create(name: "Rap, hip-hop & reggae")
    s = Subject.where{name == 'Musique & Chant'}.first
    s.children.where{name == 'Musique par instrument'}.first_or_create.children.create(name: "Violon, violoncelle & alto")

    s = Subject.where{name == 'Loisirs créatifs'}.first
    s.children.create(name: "Sérigraphie")
    s = Subject.where{name == 'Théâtre'}.first
    s.children.create(name: "Théâtre forum")
    s = Subject.where{name == 'Culture & Sciences'}.first
    s.children.where{name == 'Sciences, ciel & terre'}.first_or_create.children.create(name: "Astronomie")
    s = Subject.where{name == 'Sports'}.first
    s.children.create(name: "Gymnastique Aérobic, fitness & danse fitness")
    s = Subject.where{name == 'Informatique'}.first
    s.children.create(name: "Bureautique")
    s.children.where{name == "Initiation à l'informatique"}.first_or_create.children.create(name: "Découverte de l'informatique")
    s.children.create(name: "Infographie & PAO Infographie")
    s.children.create(name: "Infographie & PAO PAO (Publication Assistée par Ordinateur)")

    s = Subject.where{name == 'Cuisine & Vins'}.first
    s.children.where{name == "Vin & alcools"}.first_or_create.children.create(name: "Champagne")
    s.children.where{name == "Vin & alcools"}.first_or_create.children.create(name: "Dégustation de cognacs, armagnacs & eaux-de-vie")
    s.children.where{name == "Pâtisserie"}.first_or_create.children.create(name: "Crêpes, galettes & gaufres")
    s.children.where{name == "Pâtisserie"}.first_or_create.children.create(name: "Nougatine, caramel & sucres d'art")
    s.children.where{name == "Pâtisserie"}.first_or_create.children.create(name: "Pain, brioches & viennoiseries")
    s.children.where{name == "Vins & alcools"}.first_or_create.children.create(name: "Vins & mets / chocolats")

    s = Subject.where{name == 'Langues & Soutien scolaire'}.first
    s.children.where{name == "Soutien scolaire"}.first_or_create.children.create(name: "Coaching scolaire")
    s.children.where{name == "Langues & Soutien scolaire"}.first_or_create.children.create(name: "Coaching scolaire")
    s.children.where{name == "Langues & séjours linguistiques"}.first_or_create.children.create(name: "Langues indiennes")

    s = Subject.where{name == 'Sports'}.first
    s.children.where{name == "Course à pied"}.first_or_create.children.create(name: "Course à pied, running & marathon")
    s.children.where{name == "Vélo & VTT"}.first_or_create.children.create(name: "Cross, free ride & BMX")
    s.children.where{name == "Automobile & sports mécaniques"}.first_or_create.children.create(name: "Formule 1, Formule 3 & monoplace")

    s = Subject.where{name == 'Culture & Sciences'}.first
    s.children.where{name == "Sciences, ciel & terre"}.first_or_create.children.create(name: "Découverte des sciences")
    s.children.where{name == "Sciences, ciel & terre"}.first_or_create.children.create(name: "Géologie")
    s.children.where{name == "Sciences, ciel & terre"}.first_or_create.children.create(name: "Minéralogie & gemmologie")
    s.children.where{name == "Sciences, ciel & terre"}.first_or_create.children.create(name: "Météorologie")
    s.children.where{name == "Sciences, ciel & terre"}.first_or_create.children.create(name: "Orpaillage")
    s.children.where{name == "Sciences, ciel & terre"}.first_or_create.children.create(name: "Volcans")
    s.children.create(name: "Robotique")

    s = Subject.where{name == 'Gymnastique'}.first
    s.children.create(name: "Gymnastique douce, stretching & étirements")
    s.children.create(name: "Renforcement musculaire")
    s = Subject.where{name == 'Montagne'}.first
    s.children.create(name: "Snowboard, Kite & moutainboard")

    s = Subject.where{name == 'Art & Artisanat'}.first
    s.children.where{name == "Dessin & peinture"}.first_or_create.children.create(name: "Crayon, mine & fusain")
    s = Subject.where{name == 'Mode & Beauté'}.first
    s.children.where{name == "Création de vêtements "}.first_or_create.children.create(name: "Création d'accessoires, sacs & chapeaux")
    s.children.where{name == "Savoir plaire"}.first_or_create.children.create(name: "Effeuillage, cabaret & strip-tease")
    s = Subject.where{name == 'Loisirs créatifs'}.first
    s.children.create(name: "Encadrement")
    s = Subject.where{name == 'Art & Artisanat'}.first
    s.children.where{name == "Art du métal"}.first_or_create.children.create(name: "Fonderie, bronze & moulages")
    s = Subject.where{name == 'Jardinage'}.first
    s.children.where{name == "Apprentissage du jardinage"}.first_or_create.children.create(name: "Maladies, ravageurs & traitements")
    s.children.where{name == "Arbres & arbustes"}.first_or_create.children.create(name: "Taille, bouture & greffes")
    s = Subject.where{name == 'Art & Artisanat'}.first
    s.children.where{name == "Restauration d'art"}.first_or_create.children.create(name: "Patines, céruses & dorures")
    s.children.where{name == "Vitrail & travail du verre"}.first_or_create.children.create(name: "Vitrail, fusing & dalle verre")
    s = Subject.where{name == 'Déco & Bricolage'}.first
    s.children.where{name == "Décoration"}.first_or_create.children.create(name: "Peintures murales, stucs & enduits")
    s.children.where{name == "Ecoconstruction"}.first_or_create.children.create(name: "Pisé, bauge & terre")
    s = Subject.where{name == 'Nature & Animaux'}.first
    s.children.where{name == "Milieux naturels"}.first_or_create.children.create(name: "Rivière, lac, étang & mare")
    s = Subject.where{name == 'Bien-être & Santé'}.first
    s.children.where{name == "Yoga"}.first_or_create.children.create(name: "Yoga & Hatha-Yoga")
    s = Subject.where{name == 'Loisirs créatifs'}.first
    s.children.where{name == "Scrapbooking"}.first_or_create.children.create(name: "Scrapbooking & albums")
  end

  def down
  end
end
