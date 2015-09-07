class StructureSearch

  def self.similar_profile structure, limit=4
    # Choose parent subjects that are used if the profile has courses
    used_subjects = []
    used_subjects = structure.courses.includes(:subjects).flat_map(&:subjects)
    used_subjects = (used_subjects.any? ? used_subjects : structure.subjects.at_depth(2))

    results = Structure.raw_search(used_subjects.map(&:name).join(' '), { aroundLatLng: "#{structure.latitude},#{structure.longitude}",
                                             aroundPrecision: 2000,
                                             hitsPerPage: limit,
                                             facetFilters: ["id:-#{structure.id}"]
                                          })
    return results['hits'].map{ |hit| Structure.find(hit['id']) }
  end

  def self.potential_duplicates(structure)
    results = Structure.raw_search(structure.name, { hitsPerPage: 20 })
    return results['hits'].map{ |hit| Structure.find(hit['id']) }
  end

end
