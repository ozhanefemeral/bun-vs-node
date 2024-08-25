const obj = {
  foo: {
    bar: {
      baz: 123
    }
  }
}

JSON.parse(JSON.stringify(obj))