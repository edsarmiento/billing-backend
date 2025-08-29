class BaseRepository
  attr_reader :model_class

  def initialize(model_class)
    @model_class = model_class
  end

  def all
    model_class.all
  end

  def find(id)
    model_class.find(id)
  end

  def find_by(attributes)
    model_class.find_by(attributes)
  end

  def where(conditions)
    model_class.where(conditions)
  end

  def count
    model_class.count
  end

  def exists?(id)
    model_class.exists?(id)
  end

  protected

  def model
    model_class
  end
end
