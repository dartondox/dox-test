import 'package:dox_core/dox_core.dart';
import 'package:dox_mcp/dox_mcp.dart';

/// Says the text back, with the id of the user that called.
class EchoTool extends McpTool {
  @override
  String get name => 'echo';

  @override
  String get description => 'Say the text back.';

  @override
  ObjectSchema get input =>
      v.object(<String, Schema<Object?>>{'text': v.string()});

  @override
  Future<McpToolResult> call(
    Map<String, dynamic> args,
    McpContext context,
  ) async {
    IAuth? auth = context.auth as IAuth?;
    return McpToolResult.text('${args['text']} (user ${auth?.id()})');
  }
}

/// Asks "Delete this note?" first (MRTR, protocol 2026-07-28).
class DeleteNoteTool extends McpTool {
  static final McpInput<bool> confirmDelete = McpInput.confirm(
    'Delete this note?',
  );

  @override
  String get name => 'delete_note';

  @override
  String get description => 'Delete a note, after the user says yes.';

  @override
  ObjectSchema get input => v.object(<String, Schema<Object?>>{'id': v.int()});

  @override
  Future<McpToolResult> call(
    Map<String, dynamic> args,
    McpContext context,
  ) async {
    McpAnswer<bool>? answer = context.answer(confirmDelete);
    if (answer == null) {
      return McpToolResult.inputRequired(<McpInput<Object?>>[confirmDelete]);
    }
    return switch (answer) {
      McpAccepted<bool>(value: true) => McpToolResult.text(
        'Deleted note ${args['id']}',
      ),
      McpAccepted<bool>() ||
      McpDeclined<bool>() ||
      McpCancelled<bool>() => McpToolResult.text('Cancelled'),
    };
  }
}

/// Always throws, with text that must not reach a client in production.
class FailTool extends McpTool {
  @override
  String get name => 'fail';

  @override
  String get description => 'Always fails.';

  @override
  Future<McpToolResult> call(
    Map<String, dynamic> args,
    McpContext context,
  ) async {
    throw StateError('e2e secret db host 10.0.0.9');
  }
}
