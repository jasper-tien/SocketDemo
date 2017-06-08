# SocketDemo
该项目是关于socket请求的小demo。分别从最底层os层，Core Foundation层，Cocoa层三个不同层编写代码。

# iOS网络编程层次模型
iOS网络编程层次结构也分为三层：

Cocoa层：NSURL，Bonjour，Game Kit，WebKit
Core Foundation层：基于 C 的 CFNetwork 和 CFNetServices
OS层：基于 C 的 BSD socket

- Cocoa层
Cocoa层是最上层的基于 Objective-C 的 API，比如 URL访问，NSStream，Bonjour，GameKit等，这是大多数情况下我们常用的 API。Cocoa 层是基于 Core Foundation 实现的。

- Core Foundation层
Core Foundation层：因为直接使用 socket 需要更多的编程工作，所以苹果对 OS 层的 socket 进行简单的封装以简化编程任务。该层提供了 CFNetwork 和 CFNetServices，其中 CFNetwork 又是基于 CFStream 和 CFSocket。

- OS层
OS层是最底层的 BSD socket 提供了对网络编程最大程度的控制，但是编程工作也是最多的。因此，苹果建议我们使用 Core Foundation 及以上层的 API 进行编程。

