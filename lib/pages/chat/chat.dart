import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:mobile/model/chat_model.dart';
import 'package:mobile/services/chat_service.dart';
import 'package:mobile/socket/socket_manager.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/model/chat_user_model.dart';
import 'package:mobile/services/salon_service.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
//import 'package:mobile/model/multiple_image_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatState();
}

class _ChatState extends State<ChatPage> {
  ChatUserModel? user;
  List<types.Message> _messages = [];
  late types.User _sender = types.User(id: '');
  late types.User _receiver = types.User(id: '');
  StreamSubscription? _messageSubscription;
  StreamSubscription? _onlineUsersSubscription;
  DateFormat format = DateFormat("dd-MM-yyyy HH:mm:ss");
  Set<String> permission = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      ChatUserModel? userApi =
          ModalRoute.of(context)?.settings.arguments as ChatUserModel?;
      setState(() {
        user = userApi;
        _receiver = types.User(
          id: user?.id ?? '',
        );
      });
      callAPI();
      //initStatus();
      List<dynamic> onlineUsers = SocketManager().onlineUsers;
      print('userid: ${user?.id}');
      for (var onlineUser in onlineUsers) {
        print('onlineUsers: $onlineUser');
        if (onlineUser == user?.id) {
          setState(() {
            user?.isOnline = true;
          });
          break;
        } else {
          setState(() {
            user?.isOnline = false;
          });
        }
      }
    });
    _messageSubscription = SocketManager().messageStream.listen((data) {
      print(data);

      if (data['message'] != '') {
        final messageReceive = types.TextMessage(
          author: _receiver,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: data['message'],
        );
        _addMessage(messageReceive);
      }
      else
        {
          final messageReceive = types.ImageMessage(
            author: _receiver,
            id: const Uuid().v4(),
            height: 100,
            width: 100,
            name: 'Image',
            size: 100,
            uri: data['image'][0],
          );
          _addMessage(messageReceive);
        }

    });

    _onlineUsersSubscription =
        SocketManager().onlineUsersStream.listen((event) {
      print('event: $event');
      for (int i = 0; i < event.length; i++) {
        if (event[i] == user?.id) {
          setState(() {
            user?.isOnline = true;
          });
        } else {
          setState(() {
            user?.isOnline = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _messageSubscription?.cancel();
    _onlineUsersSubscription?.cancel();
  }

  void getPermission() async {
    var data = await SalonsService.getPermission();
    //setState(() {
    permission = data;
    //});
  }

  Future<void> callAPI() async {
    await getUserInfo();
    await getMessages();
    getPermission();
  }

  Future<void> getUserInfo() async {
    final Map<String, dynamic> userProfile = await APIService.getUserProfile();
    String salonId = await SalonsService.isSalon();
    if (salonId != '') {
      _sender = types.User(
        id: salonId,
      );
    } else {
      _sender = types.User(
        id: userProfile['user_id'],
      );
    }
  }

  Future<void> getMessages() async {
    //print(user!.id);
    List<ChatModel> chatAPI = await ChatService.getChatById(user!.id);
    //print(chatAPI[0].message);
    print(_sender.id);
    for (int i = 0; i < chatAPI.length; i++) {
      //print(chatAPI[i].sender);
      final createAt =
          format.parse(chatAPI[i].createdAt ?? DateTime.now().toString());
      if (chatAPI[i].message != '') {
        if (chatAPI[i].sender == _sender.id) {
          final message = types.TextMessage(
            author: _sender,
            createdAt: createAt.millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: chatAPI[i].message,
          );
          _addMessage(message);
        } else {
          final message = types.TextMessage(
            author: _receiver,
            createdAt: createAt.millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: chatAPI[i].message,
          );
          _addMessage(message);
        }
      } else {
        for (String image in chatAPI[i].images ?? []) {
          if (chatAPI[i].sender == _sender.id) {
            final message = types.ImageMessage(
              author: _sender,
              createdAt: createAt.millisecondsSinceEpoch,
              id: const Uuid().v4(),
              height: 100,
              width: 100,
              name: 'Image',
              size: 100,
              uri: image,
            );
            _addMessage(message);
          } else {
            final message = types.ImageMessage(
              author: _receiver,
              createdAt: createAt.millisecondsSinceEpoch,
              id: const Uuid().v4(),
              height: 50,
              width: 100,
              name: 'Image',
              size: 50,
              uri: image,
            );
            _addMessage(message);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            body: Chat(
              //customMessageBuilder: _customMessageBuilder,
              messages: _messages,
              onAttachmentPressed: _handleAttachmentPressed,
              onSendPressed: _handleSendPressed,
              user: _sender,
            ),
          ),
        ),
      ),
    );
  }

  // Widget _customMessageBuilder(types.Message message, {required int messageWidth}) {
  //   if (message is MultipleImageMessage) {
  //     return Row(
  //       children: message.images.map((url) => Image.network(url, width: 100, height: 100)).toList(),
  //     );
  //   }
  //   return Container();
  // }
  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _addMessageWithoutSetState(types.Message message) {
    _messages.insert(0, message);
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _sender,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );
    bool success =
        await ChatService.sendMessage(textMessage.text, user!.id, []);
    if (success) {
      _addMessage(textMessage);
    }
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              // TextButton(
              //   onPressed: () {
              //     Navigator.pop(context);
              //     _handleFileSelection();
              //   },
              //   child: const Align(
              //     alignment: AlignmentDirectional.centerStart,
              //     child: Text('File'),
              //   ),
              // ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickMultiImage(
      imageQuality: 70,
      maxWidth: 1440,
    );

    if (result.isNotEmpty) {
      List<String> images = [];
      for (var pickedFile in result) {
        final bytes = await pickedFile.readAsBytes();
        final image = await decodeImageFromList(bytes);
        final message = types.ImageMessage(
          author: _sender,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          height: 50,
          id: const Uuid().v4(),
          name: pickedFile.name,
          size: bytes.length,
          uri: pickedFile.path,
          width: 100,
        );
        _addMessage(message);
        images.add(message.uri);
      }
      bool response = await ChatService.sendMessage('', user!.id, images);
      if (response) {
        print('success');
      } else {
        print('error');
      }
    }
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _sender,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  Widget _appBar() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context, 'rebuild');
                },
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(user?.image ??
                    'https://cdn.icon-icons.com/icons2/1378/PNG/512/avatardefault_92824.png'),
              ),
              SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user!.name.length > 10 ? user!.name.substring(0, 10) + '...' : user!.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.isOnline == true ? 'Đang hoạt động' : 'Không hoạt động',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          //Expanded(child: Container()),
          // Padding(
          //   padding: EdgeInsets.only(right: 10),
          //   // child: GestureDetector(
          //   //   onTap: () {Navigator.pushNamed(context, '/call_page');},
          //   //   child: Icon(
          //   //     Icons.video_call_rounded,
          //   //     size: 30,
          //   //   ),
          //   // ),
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 50,
                child: ZegoSendCallInvitationButton(
                  iconSize: Size.fromHeight(40),
                  isVideoCall: true,
                  resourceID: "zegouikit_call",
                  //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
                  invitees: [
                    ZegoUIKitUser(id: user!.id.substring(0, 8), name: user!.name),
                  ],
                ),
              ),
              permission.length <= 0
                  ? GestureDetector(
                      onTap: () {
                        user?.reason = 'Xem xe';
                        Navigator.pushNamed(context, '/create_appointment',
                            arguments: user);
                      },
                      child: CircleAvatar(child: Icon(Icons.event)),
                    )
                  : Container(),

            ],
          ),

        ],
      ),
    );
  }
}
