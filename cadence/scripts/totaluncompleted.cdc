import "Todo"

pub fun main(address: Address): UInt64 {
    // Get Todo list public capability
    let lists = getAccount(address).capabilities.borrow<&Todo.Todolist>(Todo.TodoPublicPath) ?? panic("Todo list not found for this account")
    // Uncompleted tasks
    return lists.uncompletedtasks
}