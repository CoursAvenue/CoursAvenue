class Newsletter::Layout < ActiveHash::Base
  self.data = [
    {
      id: 1,
      blocs: ['image', 'text'],
      name: ''
    }
  ]
end
