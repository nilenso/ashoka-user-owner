module ReqConf
  class Engine < ::Rails::Engine
    isolate_namespace ReqConf

    paths["app/controllers"] << "app/controllers/"

    initializer "reqconf.concerns" do
      ActiveSupport.on_load(:action_controller) do
        include ReqConf::Concerns::RequirePasswordConfirmation
      end
    end
  end
end
