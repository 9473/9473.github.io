---
title: "Rust Intro: How Much Can We Abstract Without Losing Control?"
date: "2026-11-26"
lang: zh
section: posts
theme: code-dark
description: "从所有权、类型系统到异步与宏，理解 Rust 如何平衡抽象、资源控制与性能。"
tags: [Rust, Programming, Notes]
---

# Rust Intro: How Much Can We Abstract Without Losing Control?

Author: GPT, Zhiyan

Reference: Video [详解所有 Rust 特性](https://www.bilibili.com/video/BV1kx4F6zEow/?p=2)





本文我们介绍 Rust，可能会围绕一个核心矛盾展开：

**我们能否像高级语言一样自由地组织和表达程序，同时像低级语言一样精确地控制资源与性能？**



如果我们观察编程语言的发展，会发现一个很有意思的现象：我们似乎一直在追求两个有时相互冲突的目标。一方面，我们希望程序越来越接近人类的思维方式。我们希望使用函数、对象、类型、接口来描述问题，而不是每天考虑内存地址、寄存器和机器指令。另一方面，我们又希望程序能够充分利用计算机的性能，希望知道内存什么时候被分配、什么时候被释放，任务什么时候执行，以及程序究竟产生了多少额外开销。前者可以概括为对 Abstraction 的追求，后者是对 Control 的追求。



本文接下来列出来的一系列 Topic，都可以从这个问题出发进行串联。

- **性能与安全**：Zero-cost Abstraction、Ownership、Borrowing、RAII。
- **类型系统与抽象**：ADT、Sum Types、Product Types、Traits、Generics。
- **异步编程**：Async/Await、Future。
- **元编程**：Macros、Metaprogramming、Hygiene。
- **工程化生态**：Cargo。

其中，前两部分是理解 Rust 语言设计最重要的内容。本节的一个动机在于理解 Rust 为什么同时具有C++、Haskell、JavaScript 等语言的某些特征，而这些看似来自不同领域的思想，又为什么能够很好地共存于同一门语言中。

## Zero-cost Abstraction（零成本抽象）

### 1. 什么是 Abstraction （抽象）

Abstraction（抽象）不是让一个东西变得难以理解，而是忽略当前不关心的具体细节，只保留当前需要关心的性质。 例如，我们用 Hamiltonian 描述一个物理系统， 它们具体的相互作用、自由度乃至数学结构都不同，但我们仍然能够把它们称为 Hamiltonian，并在 Hamiltonian 这个层面讨论配分函数、能量、自由能等概念。





### 2. 零成本抽象

举个例子，假设我们要计算一组数字的平方和。我们可以这样写：

```rust
let mut sum = 0;

for i in 0..100 {
    sum += i * i;
}
```

也可以这样写：

```rust
let sum: i32 = (0..100)
    .map(|x| x * x)
    .sum();
```

第二种写法更加接近我们对这个数学问题本身的描述：对每个元素取平方，然后求和。



我们不再需要明确地描述如何维护一个中间变量，也不需要手动控制循环过程。问题是，使用这样的抽象是否意味着计算机需要做更多事情呢？

Rust 的一个核心设计理念是 Zero-cost Abstraction，零成本抽象，也继承了 C++ 的设计思想。所谓零成本抽象，是指程序员可以使用高级的语言抽象，但原则上不必为这种抽象支付额外的运行时开销。如上方那个例子，虽然使用了迭代器、闭包等高级抽象，但经过编译优化，其性能可以与手写循环相当。

Rust 的很多设计都体现了这种思想：将能够在编译期完成的检查和分析，尽量放在编译期，而不是运行时。

但我们不能说这是 Rust 的特性，因为 from C++, C++也一直追求着这样的目标。Rust 特殊的地方在于它不仅追求抽象与性能的共存，还试图将安全性纳入其中。



那么，我们究竟可以抽象什么？我们从计算机最基础的资源开始。

## **01/ Ownership、RAII、Borrowing**

考虑我们调用了一个资源之后，如何释放它？ 你有两种选择，1）程序员记得自己释放 2）Garbage Collection，也就是垃圾回收。运行时系统负责追踪对象是否仍然可达，并在适当的时候回收不再需要的内存。

传统的 C 语言允许程序员显式控制这件事情。

```c
int *data = malloc(100 * sizeof(int));

// Use data

free(data);
```

当代码量太大了程序员可能会忘了释放，进而造成内存泄露。

Rust 在这里提出一个问题：**如果编译器能够在程序运行之前就知道资源的归属，是不是就不需要在运行时通过垃圾回收来判断资源什么时候可以被释放？** 于是引出所有权 (Ownership)、生命周期 (Lifetime)等等之类的概念。 本节介绍 Ownership、RAII、Borrowing，这三个概念共同构成 Rust 的资源管理机制，但分别解决不同的问题。

#### **Ownership Rules（所有权规则）**

1. 每个值都有其所有者；
2. 所有权可以转移（Move）；
3. 通常在所有者离开作用域时，值被销毁。

> 我们直接从所有权转让这件事感受所有权.
>
> 首先创建一个自旋构型：
>
> ```rust
> let a = vec![1, -1, 1, -1];
> ```
>
> 此时，`a` 拥有这个 `Vec`，而这个 `Vec` 管理着储存在堆上的一块内存。 接下来：
>
> ```rust
> let b = a;
> ```
>
> 在 Rust 中，这里发生的是 Move，即所有权转移。 原来的堆内存并没有被完整复制，只是现在由 `b` 负责管理。 如果我们继续使用 `a`：
>
> ```rust
> println!("{:?}", a);
> ```
>
> 编译器就会拒绝这个程序。 Rust 并没有等到程序运行之后，再判断 `a` 是否可以访问这块内存，而是直接在编译阶段认定这种行为不合法。

#### **RAII（Resource Acquisition Is Initialization）**

来自 C++ 的思想，将资源的生命周期与对象的生命周期绑定。对象被销毁时，自动释放其管理的资源，例如内存、文件和锁。编译器知道谁拥有这块资源，也就知道什么时候可以释放它。 Rust 通过 `Drop` 机制实现这一思想。

这里需要强调一个概念：**Lifetime（生命周期）**，用于保证引用不会比其所引用的数据活得更久。

> 我们将资源的生命周期与管理它的对象绑定起来。
>
> ```rust
> {
>     let spins = vec![1, -1, 1, -1];
>
>     // Use spins
> }
>
> // spins is dropped here
> ```
>
> 当 `spins` 正常离开作用域时，它管理的堆内存会被自动释放。

#### **Borrowing Rules（借用规则）**

如果所有权总是需要转移，程序又会很难写。因此自然引入 Borrowing，允许在不转移所有权的情况下访问数据。

```rust
&T       // 共享借用
&mut T   // 独占可变借用
```

基本原则是：允许同时存在多个共享借用，或者一个独占可变借用。

比如，我们可以思考一个这样的问题，假设我们希望计算一个自旋构型的磁化强度。 如果计算磁化强度意味着必须把整个构型的所有权交给测量函数，这显然是不合理的，因为测量结束之后，我们还需要继续使用这个构型。

> 因此，借用自旋构型进行测量，我们可以这样写：
>
> ```rust
> fn magnetization(spins: &[i8]) -> i32 {
>     spins.iter()
>         .map(|&s| s as i32)
>         .sum()
> }
> ```
>
> 然后：
>
> ```rust
> let spins = vec![1, -1, 1, -1];
>
> let m = magnetization(&spins);
>
> println!("{:?}", spins);
> ```
>
> 这里的测量函数可以访问自旋构型，却没有获得其所有权。

Ownership 决定归属，RAII 管理释放，Borrowing 管理访问，Lifetime 保证引用的有效性。Ownership、Borrowing、Lifetime 和 RAII 在共同回答一个问题：**如何建立一套无需 GC、又能保证内存安全的资源管理规则**



## **02/ From Functional Programming：ADT**

解决了资源管理问题之后，我们开始讨论如何描述数据的类型。Rust 在这里吸收了许多函数式编程语言的思想，特别是 SML、OCaml 等语言所使用的 Algebraic Data Types。 ADT（Algebraic Data Types，代数数据类型）主要继承自 ML 系语言的思想，在 Haskell 中也非常典型。

这里我们介绍两种类型。

### Product Types & Sum Types

**Product Types（积类型）**：多个类型同时存在，逻辑上对应 AND。

```rust
struct Particle {
    position: f64,
    spin: i32,
}
```

一个粒子同时具有位置和自旋。

数学上可以理解为笛卡尔积：

$$
T=A\times B
$$



**Sum Types（和类型）**：多个可能类型中选择一个，逻辑上对应 OR。

```rust
enum Spin {
    Up,
    Down,
}
```

数学上可以理解为不交并：

$$
T=A+B
$$

Rust 中非常重要的 `Option<T>` 和 `Result<T, E>` 都是 Sum Types。

假设类型 A 有两种可能的取值，类型 B 有三种可能的取值，“积”和“和”恰好对应新类型的可能取值数量。 如果把这两种类型看作构造数据的基本运算，那么它们就像加法和乘法一样，可以不断组合出更加复杂的数据结构。



与 ADT 紧密相关的另一个重要特性是 **Pattern Matching（模式匹配）**，即 Rust 中的 `match`，用于对不同的数据结构及其状态进行分类处理。 通过 match, 编译器会检查我们是否覆盖了所有可能的状态。 当我们增加一种新的状态时，原来没有考虑这种情况的 `match` 语句就可能无法通过编译。 这体现了函数式编程中一个非常重要的思想： **Make illegal states unrepresentable.** 让不合法的状态在类型系统中无法被表示，而不是等它出现之后再去检查。



接下来，我们不仅希望描述数据，还希望描述数据能够做什么。

## **03/ Polymorphism（多态）**

如果 ADT 解决的是如何抽象数据，那么 Polymorphism 解决的就是**如何抽象行为，使同一套代码适用于不同的数据类型。**  这里提出的一个动机在于，既然我们已经可以安全地管理数据，也可以利用类型准确地描述数据，那么，能否让不同的类型共享同一种算法？（Abstraction of Behavior）

**Generics（泛型）**：对类型进行参数化。

```rust
fn identity<T>(x: T) -> T {
    x
}
```

**Traits（特征）**：定义一种类型应当具备什么行为。其思想与 Haskell 的 Type Classes 密切相关。

```rust
trait Hamiltonian {
    fn energy(&self) -> f64;
}
```

然后将两者结合：

```rust
fn measure<T: Hamiltonian>(model: &T) -> f64 {
    model.energy()
}
```

这意味着无论是 Ising model 还是 Heisenberg model，只要实现了 `Hamiltonian` trait，就可以使用同一个测量函数。

Rust 支持两种多态实现方式：

|              | Static Dispatch  | Dynamic Dispatch |
| ------------ | ---------------- | ---------------- |
| 实现方式     | `T: Trait`       | `dyn Trait`      |
| 确定具体调用 | 编译期           | 运行时           |
| 机制         | Monomorphization | 虚函数表         |
| 动态分派开销 | 无               | 有               |



其中 Monomorphization（单态化）非常有意思。 我们的代码是通用的，但计算机最终执行的代码也必须是通用的吗？ 不一定。Rust 编译器会根据实际使用的类型，对泛型代码进行特化。在这种静态分派的方式下，程序运行时并不需要再判断 model 究竟是什么类型。



## **04/ Asynchronous Programming（异步编程）**

假设我们现在需要从某个远程服务器获取模拟数据。对于普通的同步程序，程序调用读取函数之后，通常需要等待数据返回，才能继续执行后面的操作。然而，在等待的过程中，CPU 可能并没有多少事情可做。如果我们可以暂时放下这个任务，执行其他任务，等到数据准备好之后再回来继续，计算资源就可以得到更充分的利用。

这就是 Asynchronous Programming 所要解决的问题之一。这一部分与 JavaScript 的 Promise 和 Async/Await 思想相似，但实现机制不同。

| JavaScript             | Rust                     |
| ---------------------- | ------------------------ |
| Promise                | Future                   |
| `async`                | `async`                  |
| `await expression`     | `expression.await`       |
| 内置事件循环等运行环境 | 外部异步执行器，如 Tokio |

Rust 的 `Future` 本质上描述了一个尚未完成的计算过程。 一个重要区别是，Rust 的 `async` 函数返回的 Future 具有 **Laziness（惰性）**，需要被 poll 才会推进执行；而 JavaScript 的 Promise 通常在创建时就已经启动相关操作。

> 如果我们在函数前面加入 `async`：
>
> ```rust
> async fn calculate() -> i32 {
>     println!("Calculating");
>     42
> }
> ```
>
> 然后调用：
>
> ```rust
> let future = calculate();
> ```
>
> 此时，函数体还没有开始执行。我们得到的不是数字 42，而是一个 Future。通常，我们通过 `.await` 来表达这样的需求：
>
> ```rust
> let result = future.await;
> ```

但这里还有一个更深层次的问题：编译器到底如何理解这样一个可以暂停和恢复的函数？ Rust 的编译器会将 async 代码转换为状态机（State Machine），记录计算的进度。

> State Machine
>
> 假设我们有以下异步函数：
>
> ```rust
> async fn process() {
>     let data = download().await;
>
>     let result = analyze(data);
>
>     upload(result).await;
> }
> ```
>
> 这个函数有两个可能暂停的地方。概念化地表示的话相当于：
>
> ```rust
> enum ProcessState {
>     WaitingForDownload,
>     WaitingForUpload,
>     Finished,
> }
> ```
>
> 这个地方很有意思，因为我们在之前介绍 ADT 时已经遇到过对程序状态进行类型化描述的思想。 现在，这个思想又出现在了对执行过程的描述中。而 Future 本身，实际上也是一个 Trait。 执行器可以先去处理其他任务，并在相应的 Future 可以继续推进时重新调度它，而不是不断进行无意义的等待。



## **05/ Abstraction of Code: Macros（宏）**

宏属于 Metaprogramming（元编程），即编写能够生成或转换其他程序代码的程序。前面我们能够抽象数据、行为和计算过程。但如果重复的不是数据或行为，而是代码本身呢？

普通函数处理数据，而宏处理代码。 比如，通过宏，我们可以让编译器生成相应的 Trait 实现代码，而不必手动重复编写。  Rust 的宏在编译期间展开。它主要分为 Declarative Macros（声明式宏，如 `macro_rules!`）和 Procedural Macros（过程宏，如 `#[derive(Debug)]`）。这就是 Metaprogramming 的价值：将抽象进一步延伸到程序代码本身。

但让编译器自动展开或者新生成的代码可能引入新的问题：是否卫生？

**Hygiene（宏卫生性）** 是来自 Scheme 的思想，用于避免宏展开过程中发生意外的变量捕获和命名冲突。

> 假设一个宏在展开时创建了一个变量 `energy`。而调用宏的程序恰好也拥有一个名为 `energy` 的变量。两者会不会发生冲突？
>
> ```rust
> macro_rules! show {
>     ($e:expr) => {{
>         let energy = 0.0;
>         println!("Macro: {}", energy);
>         println!("Input: {}", $e);
>     }};
> }
> ```
>
> 现在调用它：
>
> ```rust
> let energy = 5.0;
>
> show!(energy);
> ```
>
> 输出为：
>
> ```text
> Macro: 0
> Input: 5
> ```
>
> 宏内部的 `energy` 与调用者传入的 `energy` 虽然名字完全相同，却仍然分别指向各自的变量。



## **06/ Abstraction at Scale: Cargo**

Cargo 不属于 Rust 的语言特性，而属于 Rust 的工程化生态。

它与 Web 开发中常见的 npm 有相似之处，但同时集成了构建、依赖管理、测试、文档生成和包发布等功能。

```
cargo new
cargo build
cargo run
cargo test
cargo add
cargo doc
```

它体现的是 Rust 将现代软件工程工具与系统级编程相结合的设计理念。



## Conclusion

我们最开始讨论的问题是：如何在使用高级抽象的同时，保留对计算机底层行为的控制？

为了回答这个问题，我们经历了多个不同的抽象层次。

- Ownership 和 Borrowing，让我们能够抽象资源的管理与访问权限。
- Algebraic Data Types，让我们能够抽象数据的结构与合法状态。
- Traits 和 Generics，让我们能够抽象不同数据类型的共同能力。
- Async 和 Future，让我们能够将尚未完成的执行过程作为对象进行组织。
- Macros，让我们能够抽象代码本身。
- 而 Cargo 则让这些抽象能够在更大规模的软件工程中被组织和共享。

如果将这些特性分别拿出来看，我们会发现，它们中的很多都不是 Rust 首创的。RAII 和单态化让我们想起 C++。ADT 和 Pattern Matching 让我们想起 ML 系的函数式语言。Traits 让我们想起 Haskell。Async/Await 让我们想起 JavaScript。 Hygienic Macros 则让我们想起 Scheme。



但是，一门语言的价值并不一定在于它发明了多少全新的概念，而在于它如何将不同的概念组织在一起，并形成一套一致的设计思路。Rust 的一个重要选择，就是让编译器能够理解更多关于程序的信息。

**程序员通过类型、所有权、借用和 Trait，将自己对程序的理解传递给编译器。**

**编译器利用这些信息进行安全性检查、代码生成和优化。**

**而最终的程序，则可以在运行时承担真正需要承担的计算与资源管理成本。**



材料 References:

- [The Rust Reference — Influences](https://doc.rust-lang.org/reference/influences.html?utm_source=chatgpt.com)：Rust 各个语言设计思想的历史来源。

- [Understanding Ownership](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html?utm_source=chatgpt.com)：所有权与资源管理。

- [Performance in Loops vs. Iterators](https://doc.rust-lang.org/book/ch13-04-performance.html?utm_source=chatgpt.com)：Zero-cost Abstraction。

- [Generic Data Types](https://doc.rust-lang.org/book/ch10-01-syntax.html?utm_source=chatgpt.com)：Generics 与 Monomorphization。

- [Futures and the Async Syntax](https://doc.rust-lang.org/book/ch17-01-futures-and-syntax.html?utm_source=chatgpt.com)：Future 的设计与惰性。

- [Tokio — join!](https://docs.rs/tokio/latest/tokio/macro.join.html?utm_source=chatgpt.com)：异步、并发与并行之间的区别。

- [Macros by Example — Hygiene](https://doc.rust-lang.org/reference/macros-by-example.html?utm_source=chatgpt.com#hygiene)：宏的卫生性。
