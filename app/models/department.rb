class Department < ApplicationRecord
  SUPPORTED = [
    OpenStruct.new(number: '01', name: 'Ain'),
    OpenStruct.new(number: '02', name: 'Aisne'),
    OpenStruct.new(number: '03', name: 'Allier'),
    OpenStruct.new(number: '04', name: 'Alpes-de-Haute-Provence'),
    OpenStruct.new(number: '05', name: 'Hautes-Alpes'),
    OpenStruct.new(number: '06', name: 'Alpes-Maritimes'),
    OpenStruct.new(number: '07', name: 'Ardèche'),
    OpenStruct.new(number: '08', name: 'Ardennes'),
    OpenStruct.new(number: '09', name: 'Ariège'),
    OpenStruct.new(number: '10', name: 'Aube'),
    OpenStruct.new(number: '11', name: 'Aude'),
    OpenStruct.new(number: '12', name: 'Aveyron'),
    OpenStruct.new(number: '13', name: 'Bouches-du-Rhône'),
    OpenStruct.new(number: '14', name: 'Calvados'),
    OpenStruct.new(number: '15', name: 'Cantal'),
    OpenStruct.new(number: '16', name: 'Charente'),
    OpenStruct.new(number: '17', name: 'Charente-Maritime'),
    OpenStruct.new(number: '18', name: 'Cher'),
    OpenStruct.new(number: '19', name: 'Corrèze'),
    OpenStruct.new(number: '21', name: "Côte-d'Or"),
    OpenStruct.new(number: '22', name: "Côtes-d'Armor"),
    OpenStruct.new(number: '23', name: 'Creuse'),
    OpenStruct.new(number: '24', name: 'Dordogne'),
    OpenStruct.new(number: '25', name: 'Doubs'),
    OpenStruct.new(number: '26', name: 'Drôme'),
    OpenStruct.new(number: '27', name: 'Eure'),
    OpenStruct.new(number: '28', name: 'Eure-et-Loir'),
    OpenStruct.new(number: '29', name: 'Finistère'),
    OpenStruct.new(number: '2A', name: 'Corse-du-Sud'),
    OpenStruct.new(number: '2B', name: 'Haute-Corse'),
    OpenStruct.new(number: '30', name: 'Gard'),
    OpenStruct.new(number: '31', name: 'Haute-Garonne'),
    OpenStruct.new(number: '32', name: 'Gers'),
    OpenStruct.new(number: '33', name: 'Gironde'),
    OpenStruct.new(number: '34', name: 'Hérault'),
    OpenStruct.new(number: '35', name: 'Ille-et-Vilaine'),
    OpenStruct.new(number: '36', name: 'Indre'),
    OpenStruct.new(number: '37', name: 'Indre-et-Loire'),
    OpenStruct.new(number: '38', name: 'Isère'),
    OpenStruct.new(number: '39', name: 'Jura'),
    OpenStruct.new(number: '40', name: 'Landes'),
    OpenStruct.new(number: '41', name: 'Loir-et-Cher'),
    OpenStruct.new(number: '42', name: 'Loire'),
    OpenStruct.new(number: '43', name: 'Haute-Loire'),
    OpenStruct.new(number: '44', name: 'Loire-Atlantique'),
    OpenStruct.new(number: '45', name: 'Loiret'),
    OpenStruct.new(number: '46', name: 'Lot'),
    OpenStruct.new(number: '47', name: 'Lot-et-Garonne'),
    OpenStruct.new(number: '48', name: 'Lozère'),
    OpenStruct.new(number: '49', name: 'Maine-et-Loire'),
    OpenStruct.new(number: '50', name: 'Manche'),
    OpenStruct.new(number: '51', name: 'Marne'),
    OpenStruct.new(number: '52', name: 'Haute-Marne'),
    OpenStruct.new(number: '53', name: 'Mayenne'),
    OpenStruct.new(number: '54', name: 'Meurthe-et-Moselle'),
    OpenStruct.new(number: '55', name: 'Meuse'),
    OpenStruct.new(number: '56', name: 'Morbihan'),
    OpenStruct.new(number: '57', name: 'Moselle'),
    OpenStruct.new(number: '58', name: 'Nièvre'),
    OpenStruct.new(number: '59', name: 'Nord'),
    OpenStruct.new(number: '60', name: 'Oise'),
    OpenStruct.new(number: '61', name: 'Orne'),
    OpenStruct.new(number: '62', name: 'Pas-de-Calais'),
    OpenStruct.new(number: '63', name: 'Puy-de-Dôme'),
    OpenStruct.new(number: '64', name: 'Pyrénées-Atlantiques'),
    OpenStruct.new(number: '65', name: 'Hautes-Pyrénées'),
    OpenStruct.new(number: '66', name: 'Pyrénées-Orientales'),
    OpenStruct.new(number: '67', name: 'Bas-Rhin'),
    OpenStruct.new(number: '68', name: 'Haut-Rhin'),
    OpenStruct.new(number: '69', name: 'Rhône'),
    OpenStruct.new(number: '70', name: 'Haute-Saône'),
    OpenStruct.new(number: '71', name: 'Saône-et-Loire'),
    OpenStruct.new(number: '72', name: 'Sarthe'),
    OpenStruct.new(number: '73', name: 'Savoie'),
    OpenStruct.new(number: '74', name: 'Haute-Savoie'),
    OpenStruct.new(number: '75', name: 'Paris'),
    OpenStruct.new(number: '76', name: 'Seine-Maritime'),
    OpenStruct.new(number: '77', name: 'Seine-et-Marne'),
    OpenStruct.new(number: '78', name: 'Yvelines'),
    OpenStruct.new(number: '79', name: 'Deux-Sèvres'),
    OpenStruct.new(number: '80', name: 'Somme'),
    OpenStruct.new(number: '81', name: 'Tarn'),
    OpenStruct.new(number: '82', name: 'Tarn-et-Garonne'),
    OpenStruct.new(number: '83', name: 'Var'),
    OpenStruct.new(number: '84', name: 'Vaucluse'),
    OpenStruct.new(number: '85', name: 'Vendée'),
    OpenStruct.new(number: '86', name: 'Vienne'),
    OpenStruct.new(number: '87', name: 'Haute-Vienne'),
    OpenStruct.new(number: '88', name: 'Vosges'),
    OpenStruct.new(number: '89', name: 'Yonne'),
    OpenStruct.new(number: '90', name: 'Territoire de Belfort'),
    OpenStruct.new(number: '91', name: 'Essonne'),
    OpenStruct.new(number: '92', name: 'Hauts-de-Seine'),
    OpenStruct.new(number: '93', name: 'Seine-Saint-Denis'),
    OpenStruct.new(number: '94', name: 'Val-de-Marne'),
    OpenStruct.new(number: '95', name: "Val-d'Oise"),
    OpenStruct.new(number: '971', name: 'Guadeloupe'),
    OpenStruct.new(number: '972', name: 'Martinique'),
    OpenStruct.new(number: '973', name: 'Guyane'),
    OpenStruct.new(number: '974', name: 'La Réunion'),
    OpenStruct.new(number: '976', name: 'Mayotte')
  ]

  validates :name, uniqueness: true, presence: true, inclusion:   {in: SUPPORTED.map(&:name) }
  validates :number, uniqueness: true, presence: true, inclusion: {in: SUPPORTED.map(&:number) }

  def self.seed_all_departments
    SUPPORTED.each { |department| Department.find_or_create_by name: department.name, number: department.number }
  end
end
