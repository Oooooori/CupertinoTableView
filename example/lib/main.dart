import 'package:cupertino_table_view/cupertino_table_view.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cupertino Table View Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
          appBar: AppBar(title: const Text('CupertinoTableView')),
          body: CupertinoTableViewDemo()),
    );
  }
}

class CupertinoTableViewDemo extends StatefulWidget {
  const CupertinoTableViewDemo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CupertinoTableViewDemoState();
}

class _CupertinoTableViewDemoState extends State<CupertinoTableViewDemo> {
  late CupertinoTableViewDelegate tableViewDelegate;
  late RefreshConfig refreshConfig;

  int numberOfSections = 5;

  @override
  void initState() {
    super.initState();
    tableViewDelegate = generateDelegate();
    refreshConfig = generateRefreshConfig();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTableView(
      delegate: tableViewDelegate,
      backgroundColor: Colors.black12,
      padding: EdgeInsets.only(left: 15, right: 15),
      refreshConfig: refreshConfig, //如果不想使用刷新能力，refreshConfig可以不传
    );
  }

  /// 创建delegate
  CupertinoTableViewDelegate generateDelegate() {
    return CupertinoTableViewDelegate(
      numberOfSectionsInTableView: () => numberOfSections,
      numberOfRowsInSection: (section) => section.isOdd ? 1 : section,
      cellForRowAtIndexPath: (context, indexPath) => Container(
        height: 60,
        color: Colors.white,
      ),
      headerInSection: (context, section) => Container(
        height: 30,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Text('this is section header'),
      ),
      footerInSection: (context, section) => Container(
        height: 30,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Text('this is section footer'),
      ),
      decorationForSection: (context, section) => BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black38,
        //     blurRadius: 3,
        //     spreadRadius: 0.5,
        //     offset: Offset(3, 3),
        //   ),
        // ],
      ),
      pressedOpacity: 0.4,
      canSelectRowAtIndexPath: (indexPath) => true,
      didSelectRowAtIndexPath: (indexPath) => print('$indexPath'),
      // marginForSection: marginForSection, // set marginForSection when using boxShadow
    );
  }

  /// 创建refreshConfig
  RefreshConfig generateRefreshConfig() {
    return RefreshConfig(
      refreshHeaderBuilder: (context, status) {
        return DefaultRefreshIndicator(
          text: 'header ${textFromStatus(status)}',
          icon: iconFromStatus(status),
        );
      },
      refreshFooterBuilder: (context, status) {
        return DefaultRefreshIndicator(
          text: 'footer ${textFromStatus(status)}',
          icon: iconFromStatus(status),
        );
      },
      onRefreshHeaderStatusChange: (controller, status) {
        if (status == RefreshStatus.refreshing) {
          Future.delayed(Duration(seconds: 3), () {
            controller.refreshHeaderStatus = RefreshStatus.completed;
            setState(() {
              numberOfSections = 10;
            });
          });
        }
      },
      onRefreshFooterStatusChange: (controller, status) {
        if (status == RefreshStatus.refreshing) {
          Future.delayed(Duration(seconds: 3), () {
            controller.refreshFooterStatus = RefreshStatus.completed;
            setState(() {
              numberOfSections = 15;
            });
          });
        }
      },
    );
  }

  EdgeInsets get marginForSection => const EdgeInsets.only(left: 10, right: 10);

  String textFromStatus(RefreshStatus status) {
    switch (status) {
      case RefreshStatus.idle:
        return 'idle';
      case RefreshStatus.prepared:
        return 'prepared';
      case RefreshStatus.refreshing:
        return 'refreshing';
      case RefreshStatus.completed:
        return 'completed';
    }
  }

  Widget iconFromStatus(RefreshStatus status) {
    switch (status) {
      case RefreshStatus.idle:
        return const Icon(Icons.arrow_upward, color: Colors.grey);
      case RefreshStatus.prepared:
        return const Icon(Icons.arrow_downward, color: Colors.grey);
      case RefreshStatus.refreshing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        );
      case RefreshStatus.completed:
        return const Icon(Icons.done, color: Colors.grey);
    }
  }
}
