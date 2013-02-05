# encoding: utf-8
FriendlyId.defaults do |config|
  config.use :reserved

  # Reserve words for French URLs
  # http://www.ranks.nl/stopwords/french.html
  config.reserved_words = %w(alors au aucuns aussi autre avant avec avoir bon car ce cela ces ceux chaque ci comme comment dans des du dedans dehors depuis deux devrait doit donc dos droite début elle elles en encore essai est et eu fait faites fois font force haut hors ici il ils je  juste la le les leur là ma maintenant mais mes mine moins mon mot même ni nommés notre nous nouveaux ou où par parce parole pas personnes peut peu pièce plupart pour pourquoi quand que quel quelle quelles quels qui sa sans ses seulement si sien son sont sous soyez sujet sur ta tandis tellement tels tes ton tous tout trop très tu valeur voie voient vont votre vous vu ça étaient état étions été être)
end
