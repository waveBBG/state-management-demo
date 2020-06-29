# state-management

各种需求场景下的状态管理方案

```sh
yarn config set registry http://registry.npm.chengfayun.net
git clone https://git.chengfayun.com/demo/dev
yarn install
yarn venv-install
cd trillion/demo/state-management
yarn start scenario1
yarn start main-svc
```

# 为什么过去状态管理不是问题？

## 2-tier 架构

远古时期，状态是完全由数据库管理的。数据库提供的连接是有状态的，打开页面的时候开连接，页面上的改动直接提交到当前的数据库连接。数据库连接的状态就是页面状态。

![state](./README/2-tier.drawio.svg)

## 3-tier 架构

后来因为互联网类型的应用的发展，数据库无法承受更多的连接。所以页面打开的时候不再开数据库连接了，仅仅在渲染和提交操作的时候才开连接拿数据。在服务端 jsp 直接渲染页面的 B/S 架构年代，状态是这样分布的

![state](./README/3-tier.drawio.svg)

这样的架构下，状态管理仍然是非常简单的。虽然有 database / jsp / html 三份状态，但是数据源只有 database 一个。所有的改动都需要先提交到 database，然后重服务端 jsp 重新渲染，客户端的 html 重新绘制。从数据迁移的角度来说，database => jsp 的网络带宽是非常高的，在内网情况下甚至 N+1 查询都不是太大的事情。如果查询实在太多了，手工写几个大 SQL 优化一下特定几个 jsp 页面的查询就好了。

## 4-tier 架构

静态 html 页面的问题是 I/O 太慢了。所有的操作都需要提交到 database，然后再完整重新渲染。虽然 Ruby on Rails 有 Render Partial 之类的优化，可以用 jquery 做一个局部 div 的全刷新。但是仍然需要在网络走一个完整的来回。现代的 Web Ui 需要操作更立即响应，需要在前端浏览器进行本地的计算和状态管理。这就事实上变成了 4 tier 的架构。

![state](./README/4-tier.drawio.svg)

React + Redux 自身是有状态的一层。然后由单向数据流绑定到了 DOM 上，DOM 本身是没有独立的状态的，完全由 React 驱动。这个架构改动的冲击是非常大的。不是所有的改动都立即提交到数据库了，而是有的时候提交到前端的 store 里就可以重新渲染了，有的时候需要提交命令给后端改数据库。同时数据状态迁移也更难做，外网的带宽低延迟高，不能像 jsp 连数据库那样随意查询。Java 提供的 JSON 接口也需要定义更复杂的数据结构来支持前端页面的渲染需求，以及提供数据校验的结果。再加上前后端分工引起的团队人员上的隔离，这个“带宽低延迟高”的特点也体现在了跨角色的沟通上。

大部分 no code / low code 的解决方案是无法给开发者提供足够的状态控制能力的。因为让开发者独立管理前端状态，比起页面绑定数据库要难太多了。所以市面上的 no code / low code 的平台从状态管理的角度来看是和远古时期的 PowerBuilder / FoxPro 非常类似的理念。

## 5-tier 架构

更现代的 Ui 要求在界面上有更及时的动效反馈。例如滑动的时候可以有弹簧的效果，页面切换的时候可以有滑出的效果。动画的特点是要求至少 30 fps，也就是在 1000 / 30 ms 的时间内要计算出一帧的数据状态，然后拿去做重渲染。用 javascript 勉强可以达到流畅，但是如果加上 React 的 virtual dom 计算就做不到流畅了。所以在 React / DOM 之间又架了一层“动画状态”层，比如 react-spring。这一层控制动效的状态可以理解为 5th tier。

![state](./README/5-tier.drawio.svg)

从 2-tier 到 5-tier 的驱动力至始至终都是相同的，就是 I/O 开销。因为动画计算不能发送到 React 端去计算，必须在 DOM 内本地计算，也是一种对 I/O 的优化。而不断优化 I/O 的背后是用户对 Ui 体验越来越苛刻的要求。

## 未来的 N-tier 架构

未来会怎么发展？会不会因为 5G 网络的发展使得 3-tier 架构复兴？目前来看，光速短期只能无法被克服，面向延迟优化的倾向是不会变的，除非现代物理学有重大突破。同时因为大家对于跨屏融合体验的要求越来越高，家里有小度的音箱，有投影仪，有手机。我们预期的是这些设备的体验是一体的，和你在一个显示器上的多个窗口不应该有本质区别。这样带来的结果必然是 5-tier 上还要再架上几层。
