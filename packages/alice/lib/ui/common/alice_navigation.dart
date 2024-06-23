import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_logger.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/call_details/page/alice_call_details_page.dart';
import 'package:alice/ui/calls_list/page/alice_calls_list_page.dart';
import 'package:alice/ui/stats/alice_stats_page.dart';
import 'package:flutter/material.dart';

/// Simple navigation helper class for Alice.
class AliceNavigation {
  static Future<void> navigateToLogList({
    required AliceCore core,
    required AliceLogger logger,
  }) {
    return _navigateToPage(
        core: core, child: AliceCallsListPage(core: core, logger: logger));
  }

  static Future<void> navigateToDetails({
    required AliceHttpCall call,
    required AliceCore core,
  }) {
    return _navigateToPage(
        core: core, child: AliceCallDetailsPage(call: call, core: core));
  }

  static Future<void> navigateToStats({required AliceCore core}) {
    return _navigateToPage(core: core, child: AliceStatsPage(core));
  }

  static Future<void> _navigateToPage({
    required AliceCore core,
    required Widget child,
  }) {
    var context = core.getContext();
    if (context == null) {
      throw StateError("Context is null in AliceCore.");
    }
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => child,
      ),
    );
  }
}
