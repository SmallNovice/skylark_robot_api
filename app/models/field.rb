class Field
  include ActiveModel::Model
  attr_accessor :id, :identity_key, :type, :title, :options, :children

  def self.build_form_field(params)
    id = params['id']
    identity_key = params['identity_key']
    type = params['type']
    title = params['title']
    options = params['options']

   Field.new(
      id: id,
      identity_key: identity_key,
      type: type,
      title: title,
      options: options
    )
  end
end
