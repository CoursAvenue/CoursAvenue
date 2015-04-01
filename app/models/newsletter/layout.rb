class Newsletter::Layout < ActiveHash::Base
  self.data = [
    {
      id: 1,
      blocs: ['image', 'text'],
      name: 'Modèle 1',
      partial: 'layout_01'
    },
    {
      id: 2,
      blocs: ['image', 'text', 'image', 'text'],
      name: 'Modèle 2',
      partial: 'layout_02'
    },
    {
      id: 3,
      blocs: ['image', 'image'],
      name: 'Modèle 3',
      partial: 'layout_03'
    },
    {
      id: 4,
      blocs: ['image', 'text', 'text'],
      name: 'Modèle 4',
      partial: 'layout_04'
    }
  ]
end
