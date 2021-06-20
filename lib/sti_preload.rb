# Preload Single Table Inheritance
# https://guides.rubyonrails.org/autoloading_and_reloading_constants.html
module StiPreload
  unless Rails.application.config.eager_load
    extend ActiveSupport::Concern

    included do
      cattr_accessor :preloaded, instance_accessor: false
    end

    class_methods do
      def descendants
        preload_sti unless preloaded
        super
      end

      def preload_sti
        types_in_db = base_class
                      .unscoped
                      .select(inheritance_column)
                      .distinct
                      .pluck(inheritance_column)
                      .compact

        types_in_db.each(&:constantize)

        self.preloaded = true
      end
    end
  end
end
