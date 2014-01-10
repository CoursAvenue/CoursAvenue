class PassionExpectation < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
      { id: 1, name: 'passions.expectations.discover'  },
      { id: 2, name: 'passions.expectations.get_back'  },
      { id: 3, name: 'passions.expectations.curiosity' },
      { id: 4, name: 'passions.expectations.health'    },
      { id: 5, name: 'passions.expectations.moral'     },
      { id: 6, name: 'passions.expectations.passion'   },
      { id: 7, name: 'passions.expectations.other'     }
  ]
end
