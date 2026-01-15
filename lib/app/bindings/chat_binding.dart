import 'package:get/get.dart';
import '../../data/repositories/chat_repository.dart';
import '../../modules/chat/chat_list/chat_list_controller.dart';
import '../../modules/chat/chat_detail/chat_detail_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatRepository>(() => ChatRepository());
    Get.lazyPut<ChatListController>(() => ChatListController());
    Get.lazyPut<ChatDetailController>(() => ChatDetailController());
  }
}
