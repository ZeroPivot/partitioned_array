if __name__ == "__main__":
    LENGTH_OF_BUFFER = 16
    receiver = Receiver(LENGTH_OF_BUFFER)
    while True:
        event_data = input()     # user input
        receiver.event(event_data)  # most of what takes place here is in receiver.rb
        


def test_receiver():
    # Initialize the receiver with a buffer length of 10
    receiver = Receiver(10)

    # Test padder method
    assert receiver.padder(1) == '00001'
    assert receiver.padder(12345) == '12345'

    # Test range method
    assert receiver.get_range() == range(1, 11)
    receiver.set_range(range(11, 21))
    assert receiver.get_range() == range(11, 21)

    # Test min_seq and max_seq methods
    assert receiver.min_seq() == 1
    assert receiver.max_seq() == 10

    # Test full? method
    assert not receiver.is_full()
    receiver.list.fill({'seq': i, 'data': None, 'have': True} for i in range(1, 11))
    assert receiver.is_full()

    # Test change_offset method
    receiver.change_offset(100)
    assert receiver.offset == 100
    assert receiver.get_range() == range(100, 110)

    # Test nak_check method
    assert not receiver.nak_check()
    receiver.list[3]['have'] = False
    assert receiver.nak_check()

    # Test change_location method
    receiver.change_location(105)
    assert receiver.location['seq'] == 105

def change_location(self, frame):
    for node in self.list:
        if node['seq'] == frame:
            self.location = node
            break
    return self.location


Copy code
class Receiver:
    LENGTH = 50
    MAX_BOUND = 99999

    def __init__(self, length, offset=0):
        if length == 0:
            raise ValueError("length cannot be 0")
        self.debug = False
        self.receiving = False
        self.offset = offset
        self.list = LinkedList()
        self.length = length
        for i in range(self.length):
            self.list.insert_back({'seq': self.offset + i + 1, 'data': None, 'have': False})
        self.set_range(range(self.offset, self.list.get_last_node()['seq'] + 1))
        self.location = self.list.get_first_node()

    def padder(self, seqnum, syn_max_len=5):
        if len(str(seqnum)) <= syn_max_len:
            return "0" * (syn_max_len - len(str(seqnum))) + str(seqnum)
        return str(seqnum)

    def get_range(self):
        return self._range

    def set_range(self, rng):
        self._range = rng

    def get_list(self):
        return self.list

    def min_seq(self):
        return self.list.get_first_node()['seq']

    def max_seq(self):
        return self.list.get_last_node()['seq']

    def debug(self, string):
        if self.debug:
            print(string)

    def nak(self, loc=None):
        if loc is None:
            print("NAK " + self.padder(self.location['seq']))
        else:
            print("NAK " + self.padder(loc))

    def ack(self, val=None):
        if val is None:
            print("ACK " + self.padder(self.location['seq']))
        else:
            print("ACK " + self.padder(val))

    def multi(self):
        yield

    def is_full(self):
        for node in self.list:
            if not node['have']:
                return False
        return True

    def no_has(self):
        for node in self.list:
            node['have'] = False

    def change_offset(self, offset):
        for node in self.list:
            self.debug("before: " + str(node['seq']))
            node['seq'] -= self.offset
            node['seq'] += offset
            self.debug("after: " + str(node['seq']))
        self.offset = offset
        self.set_range(range(self.offset, self.list.get_last_node()['seq'] + 1))

    def nak_check(self):
        for node in self.list:
            if node['seq'] > self.location['seq']:
                return False
            if not node['have']:
                self.nak(node['seq'])
                return True
        return False


def change_location(self, frame):
    for node in self.list:
        if node['seq'] == frame:
            self.location = node
            break
    return self.location
  
  

test_receiver()