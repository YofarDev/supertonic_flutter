#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include "supertonic_flutter/supertonic_flutter_plugin.h"

#define SUPERTONIC_FLUTTER_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), supertonic_flutter_plugin_get_type(), SupertonicFlutterPlugin))

struct _SupertonicFlutterPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(SupertonicFlutterPlugin, supertonic_flutter_plugin,
               g_object_get_type())

static void supertonic_flutter_plugin_dispose(GObject *object) {
  G_OBJECT_CLASS(supertonic_flutter_plugin_parent_class)->dispose(object);
}

static void supertonic_flutter_plugin_class_init(
    SupertonicFlutterPluginClass *klass) {
  G_OBJECT_CLASS(klass)->dispose = supertonic_flutter_plugin_dispose;
}

static void supertonic_flutter_plugin_init(SupertonicFlutterPlugin *self) {}

static void method_call_handler(FlMethodChannel *channel,
                                 FlMethodCall *method_call,
                                 gpointer user_data) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar *method = fl_method_call_get_name(method_call);

  if (g_strcmp0(method, "getPlatformVersion") == 0) {
    response = FL_METHOD_RESPONSE(
        fl_method_success_response_new(fl_value_new_string("Linux")));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

void supertonic_flutter_plugin_register_with_registrar(
    FlPluginRegistrar *registrar) {
  SupertonicFlutterPlugin *plugin = SUPERTONIC_FLUTTER_PLUGIN(
      g_object_new(supertonic_flutter_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "supertonic_flutter",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_handler,
                                            plugin, nullptr);

  g_object_unref(plugin);
}
