帮我基于Maven创建一个JavaFX项目

## 要求

1. java版本：24
2. javafx版本： 24
3. 提供基于github actions的多平台交叉编译workflow，包括windows、macos、linux以及android（ARM），ios如果可以的话，也可以提供；
   - push事件或者手动触发执行
   - push tag的时候，编译所有平台制品并发布，发布页面的物料列表里有相应的下载链接。
   - 没有tag的push，只执行编译，不执行发布。
4. 包含最基本的一个javafx程序，可以直接打包执行；
5. Desktop上，发布以onejar形式+相应平台启动脚本打包供用户可下载使用(onejar即可以直接`java -jar app.jar`执行的jar包形式)
6. Mobile上，发布为相应的package格式。


## 注意

- android包打包需要在arm的runner上跑，而不是x86/64的runner上。
