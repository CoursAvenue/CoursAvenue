class Newsletter::Layout < ActiveHash::Base
  self.data = [
    {
      id: 1,
      blocs: ['image', 'text'],
      name: 'Modèle 1',
      partial: 'layout_01',
      disposition: :horizontal,
      sub_blocs: [],
      proportions: [],
      proportions_in_px: []
    },
    {
      id: 2,
      blocs: ['image', 'text', 'image', 'text'],
      name: 'Modèle 2',
      partial: 'layout_02',
      disposition: :horizontal,
      sub_blocs: [],
      proportions: [],
      proportions_in_px: []
    },
    {
      id: 3,
      blocs: ['multi', 'multi'],
      name: 'Modèle 3',
      partial: 'layout_03',
      disposition: :horizontal,
      sub_blocs: [['image', 'text'], ['text', 'image']],
      proportions: [['one-quarter', 'three-quarters'], ['three-quarters', 'one-quarter']],
      proportions_in_px: [['150', '450'], ['450', '150']]
    },
    {
      id: 4,
      blocs: ['multi', 'multi'],
      name: 'Modèle 4',
      partial: 'layout_04',
      disposition: :vertical,
      sub_blocs: [['image', 'text'], ['image', 'text']],
      proportions: [],
      proportions_in_px: []
    }
  ]

  # To be able to serialize data with serialize
  def serializable_hash
    self.attributes
  end
end
