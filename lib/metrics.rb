module Metrics
  def self.included(klass)
    if klass.name == 'Pod'
      @metrics_classes.each do |metrics_class|
        klass.one_to_one metrics_class.name.underscore.to_sym
        metrics_class.install_accessor_methods_on(klass)
        metrics_class.install_with_method(klass)
      end
    else
      @metrics_classes ||= []
      @metrics_classes << klass

      klass.many_to_one :pod

      install_helper_methods(klass)
      install_installer_methods(klass)
    end
  end

  def self.install_helper_methods(klass)
    class<<klass
      def prefix
        table_name.to_s.gsub('_metrics', '')
      end

      def aliased_columns
        @aliased_columns ||= columns.map do |name|
          :"#{table_name}__#{name}___#{prefix}_#{name}"
        end
      end

      def install_accessor_methods_on(model)
        columns.each do |name|
          prefixed_name = :"#{prefix}_#{name}"
          model.send(:define_method, prefixed_name) do
            self[prefixed_name]
          end
        end
      end
    end
  end

  def self.install_installer_methods(metrics_class)
    table_name = metrics_class.table_name
    metrics_class.__metaclass__.send(:define_method, :install_with_method) do |klass|
      klass.__metaclass__.send(:define_method, :"with_#{table_name}") do
        left_join(table_name, :pod_id => :id)
          .select_append(*metrics_class.aliased_columns)
      end
    end
  end
end
