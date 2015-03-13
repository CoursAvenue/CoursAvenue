class Newsletter::Layout < ActiveHash::Base
  self.data = [
    {
      id: 0,
      blocs: ['image', 'text'],
      name: 'Layout #01',
      partial: 'layout_01'
    },
    {
      id: 1,
      blocs: ['text', 'text'],
      name: 'Layout #02',
      partial: 'layout_02'
    },
    {
      id: 2,
      blocs: ['image', 'image'],
      name: 'Layout #03',
      partial: 'layout_03'
    },
    {
      id: 3,
      blocs: ['image', 'text', 'text'],
      name: 'Layout #04',
      partial: 'layout_04'
    },
    {
      id: 4,
      blocs: ['image', 'text', 'image', 'text'],
      name: 'Layout #05',
      partial: 'layout_05'
    },
  ]
end
