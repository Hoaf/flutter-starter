import 'package:event_bus/event_bus.dart';

class EventBusUtils {
  static final EventBus _eventBus = EventBus();
  static void sendEvent(Object event) {
    _eventBus.fire(event);
  }

  static EventBus getEventBus() {
    return _eventBus;
  }
}