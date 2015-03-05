class Newsletter::Layout < ActiveHash::Base
  self.data = [
    {
      id: 0,
      blocs: ['image', 'text'],
      name: 'Layout #01'
    },
    {
      id: 1,
      blocs: ['image', 'text'],
      name: 'Layout #02'
    },
    {
      id: 2,
      blocs: ['image', 'text'],
      name: 'Layout #03'
    },
    {
      id: 3,
      blocs: ['image', 'text'],
      name: 'Layout #04'
    },
    {
      id: 4,
      blocs: ['image', 'text'],
      name: 'Layout #05'
    },
  ]
end
