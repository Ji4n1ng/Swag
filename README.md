# Swag

A toy wasm interpreter written in Swift.

## Wait... but why 🤔

Since the community has many wasm implementations, both inside and outside the browser, why write another one? Emmmmm... just want to learn wasm.

> What I cannot create, I do not understand. \- Richard Feynman

## Under construction 👷‍♂️ 🚧

- **Binary**
    - [x] **Types** Swift structs translated from Wasm binary format
    - [x] **Docoder** Wasm binary format decoder
- **Interpreter**
    - [x] Operand stack
    - [x] Memory
    - [x] Control stack
    - [x] Global
    - [x] Instructions
        - [x] Parametric Instructions
        - [x] Numeric Instructions
        - [x] Memory Instructions
        - [x] Variable Instructions
        - [x] Control Instructions
    - [ ] Error handling
        - [x] Parse
        - [ ] Interpreter 
- **Validator**
    - [ ] Module validator
    - [ ] Code validator
- **Tests**
    - [x] Instructions
    - [x] Hello World
    - [x] Fibonacci
    - [x] Factorial
    - [x] Memory
    - [x] Calc


## Reference project ❤️

Special thanks to [zxh0/wasmgo-book](https://github.com/zxh0/wasmgo-book)
