#include <gtkmm/application.h>
#include <gtkmm/applicationwindow.h>
#include <gtkmm/button.h>

// main window of the application
class HelloWorldWindow : public Gtk::ApplicationWindow {
    // a simple push button
    Gtk::Button btn;
public:
    HelloWorldWindow()
    : btn("Click me!") {// initialize button with a text label
        // when user presses the button "clicked" signal is emitted
        // connect an event handler for the signal with connect()
        // which accepts lambda expression, among other things
        btn.signal_clicked().connect(
        [this]() {
            btn.set_label("Hello World");
        });
        // add the push button to the window
        add(btn);
        // make the window visible
        show_all();
    }
};

int main(int argc, char *argv[]) {
     // This creates an Gtk+ application with an unique application ID
     auto app = Gtk::Application::create(argc, argv, "org.gtkmm.example.HelloApp");
     HelloWorldWindow hw;
     // this starts the application with our window
     // close the window to terminate the application
     return app->run(hw);
}
