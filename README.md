# CupertinoTableView
iOS style table view in flutter

一个可高度自定义的iOS风格的TableView Flutter插件。
使用Delegate的方式控制tableView的显示、处理回调等，提供丰富的Delegate配置选项。
在有默认实现的同时，可以自定义cell、header、footer、分割线，还可以对每个section提供decoration等等。
同时CupertinoTableView自带上拉/下拉刷新功能，可以通过传递RefreshConfig进行自定义配置。

![example](example/resource/example.gif)

```
  /// 创建delegate控制tableView的显示和点击响应等
  CupertinoTableViewDelegate generateDelegate() {
    return CupertinoTableViewDelegate(
      numberOfSectionsInTableView: () => numberOfSections,
      numberOfRowsInSection: (section) => (section + 1) * 2,
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
  
  /// 创建RefreshConfig控制tableView的下拉/上拉刷新和其回调
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
              numberOfSections = 3;
            });
          });
        }
      },
      onRefreshFooterStatusChange: (controller, status) {
        if (status == RefreshStatus.refreshing) {
          Future.delayed(Duration(seconds: 3), () {
            controller.refreshFooterStatus = RefreshStatus.completed;
            setState(() {
              numberOfSections = 5;
            });
          });
        }
      },
    );
  }

  /// 创建一个CupertinoTableView
  Widget build(BuildContext context) {
    return CupertinoTableView(
      delegate: tableViewDelegate,
      backgroundColor: Colors.black12,
      padding: EdgeInsets.only(left: 15, right: 15),
      refreshConfig: refreshConfig, //如果不想使用刷新能力，refreshConfig可以不传
    );
  }

```
