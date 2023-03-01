## 1.0.0

* Create CupertinoTableView with Refresh Header&Footer

## 1.0.1

* 代码优化

1. 调整设置pressedOpacity的方法，现在放到delegate中设置
2. 去掉多余的依赖库
3. 以来dart版本降级，现在最低支持dart2.12
4. 补充部分注释和readme
5. 修复当不设置section decoration时的异常

## 1.0.2

* 修复bug

1. 修复当没有mounted的时候收到PostFrameCallback时发生的异常，可能在pageView中会遇到这种情况
2. physics默认设置为const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())
