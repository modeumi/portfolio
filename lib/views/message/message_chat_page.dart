import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:portfolio/views/message/widgets/message_field.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/import_package.dart';
import 'package:portfolio/core/widgets/app_modal.dart';
import 'package:utility/textstyle.dart';

class MessageChatPage extends ConsumerStatefulWidget {
  const MessageChatPage({super.key});

  @override
  ConsumerState<MessageChatPage> createState() => _MessageChatPageState();
}

class _MessageChatPageState extends ConsumerState<MessageChatPage> with RiverpodMixin {
  ScrollController scroll = ScrollController();
  TextEditingController content = TextEditingController();
  TextEditingController setupPassword = TextEditingController();

  bool answer = false; // 관리자 답변 모드
  bool lock = false; // 신규 대화 비공개 설정값(설정 카드에서 지정)

  bool _isNewChat = false; // 처음 만든 대화 → 비밀번호 설정 단계 필요
  bool _pwReady = false; // 이번 세션에서 비밀번호 확보 여부
  String _sessionPw = ''; // 확보된 비밀번호
  bool _setupError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await layoutController.withLoading(() async {
        await messageController.loadChat(true);
      });
      // 입장 시 확인한 비밀번호(잠긴 대화 재입장 등)를 인수해 재입력 방지
      _sessionPw = messageController.enteredPassword;
      messageController.enteredPassword = '';
      if (!mounted) return;
      setState(() {
        _isNewChat = messageState.target!.lastContent == null && !layoutState.admin;
        _pwReady = layoutState.admin || _sessionPw.isNotEmpty;
      });
      await scrollToBottom();
    });
  }

  Future<void> scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (scroll.hasClients) {
      scroll.animateTo(scroll.position.maxScrollExtent, duration: const Duration(microseconds: 300), curve: Curves.easeOut);
    }
  }

  void _infoDialog(String title, String body) {
    layoutController.changeDialogState(true);
    showDialog(
      context: context,
      builder: (context) => ModalWidget(
        title: title,
        content: body,
        width: 400,
        action: () => layoutController.changeDialogState(false),
        select_button: true,
      ),
    );
  }

  // 기존 대화 이어쓰기: 처음 설정한 비밀번호 확인 (1회)
  Future<bool> _verifyPassword() async {
    final TextEditingController pw = TextEditingController();
    bool valid = true;
    layoutController.changeDialogState(true);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => ModalWidget(
          title: '비밀번호 확인',
          contentWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Text('이 대화를 이어가려면\n처음 설정한 비밀번호를 입력하세요.', style: black(17, FontWeight.w500), textAlign: TextAlign.center),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(width: 1, color: color_grey)),
                  child: CustomTextField(controller: pw, hint: '비밀번호 입력', obscure: true, maxLine: 1),
                ),
                if (!valid) Text('비밀번호가 일치하지 않습니다', style: custom(15, FontWeight.w400, color_red)),
              ],
            ),
          ),
          width: 400,
          action: () {
            final bool match = messageController.checkPassword(pw.text);
            setLocal(() => valid = match);
            if (match) {
              _sessionPw = pw.text;
              layoutController.changeDialogState(false);
              Navigator.pop(context, true);
            }
          },
          cancle: () => layoutController.changeDialogState(false),
          submitButtonContent: '확인',
          cancleButtonContent: '취소',
        ),
      ),
    );
    if (ok == true) {
      if (mounted) setState(() => _pwReady = true);
      return true;
    }
    return false;
  }

  // 메시지 전송 (텍스트/이미지 공용)
  Future<void> _send(String body, {required bool clearOnSuccess}) async {
    if (body.trim() == '') return;
    // 방문자: 비밀번호 미확보 시 확인 단계
    if (!answer && !_pwReady) {
      final bool ok = await _verifyPassword();
      if (!ok) return;
    }
    String result = '';
    await layoutController.withLoading(() async {
      result = await messageController.sendChat(body, answer ? '' : _sessionPw, answer, lock);
    });
    if (!mounted) return;
    if (result == 'pass') {
      if (clearOnSuccess) content.clear();
      await layoutController.withLoading(() async {
        await messageController.loadChat();
        await messageController.loadChatList();
      });
      await scrollToBottom();
    } else if (result == 'password') {
      setState(() => _pwReady = false);
      _infoDialog('비밀번호 오류', '비밀번호가 일치하지 않습니다.\n확인 후 다시 시도해주세요.');
    } else {
      _infoDialog('오류', '일시적인 오류가 발생하였습니다.\n잠시 후 다시 시도해주세요.');
    }
  }

  Future<void> _sendImage() async {
    if (!answer && !_pwReady) {
      final bool ok = await _verifyPassword();
      if (!ok) return;
    }
    if (!mounted) return;
    final String url = await messageController.imagePickAndUpload(context);
    if (url == '') return;
    await _send(url, clearOnSuccess: false);
  }

  @override
  Widget build(BuildContext context) {
    final bool existing = messageState.target!.lastContent != null;
    return PopScope(
      canPop: layoutState.dialogOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (layoutState.dialogOpen) {
          layoutController.changeDialogState(false);
        }
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(color: pWhite),
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(
              children: [
                // 상단: 뒤로 + 대화 상대
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    spacing: 20,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: SvgPicture.asset('assets/images/top_back.svg', colorFilter: ColorFilter.mode(secondary, BlendMode.srcIn)),
                      ),
                      Expanded(
                        child: Text(messageState.target!.name ?? '대상오류', style: custom(25, FontWeight.w700, secondary), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                // 컨트롤: 관리자 답변 토글 / 기존 대화 비공개 토글
                if (layoutState.admin || existing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 5,
                      children: [
                        if (layoutState.admin)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            spacing: 5,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => answer = !answer),
                                child: Icon(answer ? Icons.check_box : Icons.check_box_outline_blank_rounded, color: answer ? pBackBlack : color_grey),
                              ),
                              Text('답변', style: grey(18, FontWeight.w500)),
                            ],
                          ),
                        // 기존 대화의 비공개 변경(비밀번호 확인 후 토글)
                        if (existing)
                          Row(
                            spacing: 5,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final TextEditingController lockPassword = TextEditingController();
                                  bool validPassword = true;
                                  layoutController.changeDialogState(true);
                                  showDialog(
                                    context: context,
                                    builder: (context) => StatefulBuilder(
                                      builder: (context, setLocal) {
                                        return ModalWidget(
                                          title: '비밀번호 입력',
                                          contentWidget: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 30),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(width: 1, color: color_grey),
                                                  ),
                                                  child: CustomTextField(controller: lockPassword, hint: '비밀번호 입력', obscure: true, maxLine: 1),
                                                ),
                                                validPassword ? const Text('') : Text('비밀번호가 일치하지 않습니다', style: custom(18, FontWeight.w400, color_red)),
                                              ],
                                            ),
                                          ),
                                          width: 400,
                                          action: () {
                                            setLocal(() => validPassword = messageController.checkPassword(lockPassword.text));
                                            if (validPassword) {
                                              layoutController.changeDialogState(false);
                                              layoutController.withLoading(() async {
                                                await messageController.setLock();
                                                if (context.mounted) Navigator.pop(context);
                                              });
                                            }
                                          },
                                          cancle: () => layoutController.changeDialogState(false),
                                          submitButtonContent: '확인',
                                          cancleButtonContent: '취소',
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Icon(
                                  messageState.target!.lock! ? Icons.check_box : Icons.check_box_outline_blank_rounded,
                                  color: messageState.target!.lock! ? pBackBlack : color_grey,
                                ),
                              ),
                              Text('비공개', style: grey(18, FontWeight.w500)),
                              GestureDetector(
                                onTap: () => _infoDialog('안내', '비공개를 선택 시 해당 채팅에 진입할 때 비밀번호를 입력해야 열람 및 채팅 입력이 가능합니다.'),
                                child: Icon(Icons.info, color: color_grey),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                // 메세지 출력 라인
                Expanded(
                  child: SingleChildScrollView(
                    controller: scroll,
                    child: Column(
                      children: [
                        for (var i in messageState.chats.entries)
                          Column(
                            spacing: 10,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                                child: Row(
                                  spacing: 15,
                                  children: [
                                    Flexible(child: Container(width: double.infinity, height: 1, decoration: BoxDecoration(color: color_grey))),
                                    Text(i.key, style: grey(15, FontWeight.w500)),
                                    Flexible(child: Container(width: double.infinity, height: 1, decoration: BoxDecoration(color: color_grey))),
                                  ],
                                ),
                              ),
                              for (var j in i.value.entries)
                                for (var k in j.value)
                                  MessageField(
                                    type: k.name == messageState.target!.name,
                                    time: reforme_time_short('m:', k.createAt!),
                                    content: k.message!,
                                    last: j.value.last == k,
                                  ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                // 입력 라인 (이미지 + 텍스트 + 전송)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Row(
                    spacing: 15,
                    children: [
                      GestureDetector(
                        onTap: _sendImage,
                        child: SvgPicture.asset('assets/images/image.svg', width: 40),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                          decoration: BoxDecoration(color: back_grey_2, borderRadius: BorderRadius.circular(30)),
                          child: CustomTextField(controller: content, hint: '메세지를 입력해주세요.', fontSize: 19, fontWeight: FontWeight.w500),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _send(content.text, clearOnSuccess: true),
                        child: SvgPicture.asset('assets/images/message/send.svg', width: 40),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 신규 대화: 비밀번호 설정 단계 (한 번)
          if (_isNewChat && !_pwReady)
            Positioned.fill(
              child: Container(
                color: pBackBlack.withValues(alpha: 0.45),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: pWhite, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 14,
                    children: [
                      Text('대화 시작하기', style: black(22, FontWeight.w800)),
                      Text(
                        '이 대화에는 비밀번호가 설정됩니다.\n나중에 이어서 작성하거나 다시 보려면 이 비밀번호가 필요해요.',
                        style: custom(15, FontWeight.w500, font_grey),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(width: 1, color: color_grey)),
                        child: CustomTextField(controller: setupPassword, hint: '사용할 비밀번호 입력', obscure: true, maxLine: 1),
                      ),
                      if (_setupError) Text('비밀번호를 입력해주세요.', style: custom(13, FontWeight.w400, color_red)),
                      GestureDetector(
                        onTap: () => setState(() => lock = !lock),
                        child: Row(
                          spacing: 8,
                          children: [
                            Icon(lock ? Icons.check_box : Icons.check_box_outline_blank_rounded, color: lock ? secondary : color_grey),
                            Expanded(child: Text('비공개로 설정 (목록에서 숨기고 입장 시 비밀번호 필요)', style: custom(14, FontWeight.w500, font_grey))),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () {
                            if (setupPassword.text.trim() == '') {
                              setState(() => _setupError = true);
                              return;
                            }
                            setState(() {
                              _sessionPw = setupPassword.text;
                              _pwReady = true;
                              _setupError = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: secondary, borderRadius: BorderRadius.circular(12)),
                            child: Text('이 비밀번호로 대화 시작', style: white(16, FontWeight.w700)),
                          ),
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Text('취소', style: custom(14, FontWeight.w500, font_grey)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
