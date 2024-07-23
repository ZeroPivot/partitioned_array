# Node structure for the Red-Black Tree
class Node
  attr_accessor :data, :color, :left, :right, :parent, :object

  def initialize(data)
    @data = data
    @color = "RED"
    @object = nil
    @left = nil
    @right = nil
    @parent = nil
  end
end

# Red-Black Tree class
class RedBlackTree
  def initialize
    @nil = Node.new(0)
    @nil.color = "BLACK"
    @nil.left = @nil
    @nil.right = @nil
    @root = @nil
  end

  # Utility function to perform left rotation
  def left_rotate(x)
    y = x.right
    x.right = y.left
    if y.left != @nil
      y.left.parent = x
    end
    y.parent = x.parent
    if x.parent == nil
      @root = y
    elsif x == x.parent.left
      x.parent.left = y
    else
      x.parent.right = y
    end
    y.left = x
    x.parent = y
  end

  # Utility function to perform right rotation
  def right_rotate(x)
    y = x.left
    x.left = y.right
    if y.right != @nil
      y.right.parent = x
    end
    y.parent = x.parent
    if x.parent == nil
      @root = y
    elsif x == x.parent.right
      x.parent.right = y
    else
      x.parent.left = y
    end
    y.right = x
    x.parent = y
  end

  # Function to fix Red-Black Tree properties after
  # insertion
  def fix_insert(k)
    while k != @root && k.parent.color == "RED"
      if k.parent == k.parent.parent.left
        u = k.parent.parent.right # uncle
        if u.color == "RED"
          k.parent.color = "BLACK"
          u.color = "BLACK"
          k.parent.parent.color = "RED"
          k = k.parent.parent
        else
          if k == k.parent.right
            k = k.parent
            left_rotate(k)
          end
          k.parent.color = "BLACK"
          k.parent.parent.color = "RED"
          right_rotate(k.parent.parent)
        end
      else
        u = k.parent.parent.left # uncle
        if u.color == "RED"
          k.parent.color = "BLACK"
          u.color = "BLACK"
          k.parent.parent.color = "RED"
          k = k.parent.parent
        else
          if k == k.parent.left
            k = k.parent
            right_rotate(k)
          end
          k.parent.color = "BLACK"
          k.parent.parent.color = "RED"
          left_rotate(k.parent.parent)
        end
      end
    end
    @root.color = "BLACK"
  end

  # Inorder traversal helper function
  def inorder_helper(node)
    if node != @nil
      inorder_helper(node.left)
      puts node.data.to_s + " "
      inorder_helper(node.right)
    end
  end

  # Search helper function
  def search_helper(node, data)
    if node == @nil || data == node.data
      return node
    end
    if data < node.data
      return search_helper(node.left, data)
    end
    return search_helper(node.right, data)
  end

  # Insert function
  def insert(data)
    new_node = Node.new(data)
    new_node.left = @nil
    new_node.right = @nil

    parent = nil
    current = @root

    # BST insert
    while current != @nil
      parent = current
      if new_node.data < current.data
        current = current.left
      else
        current = current.right
      end
    end

    new_node.parent = parent

    if parent == nil
      @root = new_node
    elsif new_node.data < parent.data
      parent.left = new_node
    else
      parent.right = new_node
    end

    if new_node.parent == nil
      new_node.color = "BLACK"
      return
    end

    if new_node.parent.parent == nil
      return
    end

    fix_insert(new_node)
  end

  # Inorder traversal
  def inorder
    inorder_helper(@root)
  end

  # Search function
  def search(data)
    search_helper(@root, data)
  end
end

rbt = RedBlackTree.new

# Inserting elements
rbt.insert(10)
rbt.insert(20)
rbt.insert(30)
rbt.insert(15)

# Inorder traversal
puts "Inorder traversal:"
rbt.inorder # Output: 10 15 20 30

# Search for a node
puts "\nSearch for 15: " + (rbt.search(15) != rbt.search(0)).to_s # Output: true
puts "Search for 25: " + (rbt.search(25) != rbt.search(0)).to_s # Output: false
