class Newsletter::Layout < ActiveHash::Base
  self.data = [
    {
      id: 1,
      blocs: ['image', 'text'],
      name: 'Layout #01',
      partial: 'layout_01'
    },
    {
      id: 2,
      blocs: ['image', 'text', 'image', 'text'],
      name: 'Layout #02',
      partial: 'layout_02'
    },
    {
      id: 3,
      blocs: ['image', 'image'],
      name: 'Layout #03',
      partial: 'layout_03'
    },
    {
      id: 4,
      blocs: ['image', 'text', 'text'],
      name: 'Layout #04',
      partial: 'layout_04'
    }
  ]
end
