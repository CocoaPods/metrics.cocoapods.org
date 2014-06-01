class Object
  def self.__metaclass__
    class<<self; return self; end
  end
end
