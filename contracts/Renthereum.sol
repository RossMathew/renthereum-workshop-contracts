pragma solidity ^0.4.14;

contract Renthereum {

  enum Status {
    AVAILABLE,
    CANCELED,
    RENTED
  }

  mapping(uint256 => Order) public itemsForHire;
  uint256 public itemsCount;
  
  struct Order {
    string id;
    address owner;
    address customer;
    string name;
    string description;
    uint256 dailyValue;
    uint minPeriod;
    uint maxPeriod;
    uint hirePeriod;
    Status status;
  }

  event Ordered(
    string _id,
    address _owner,
    string _name,
    uint256 _value
  );

  event Rented(
    address _owner,
    address _customer,
    uint _period,
    uint256 _value
  );

  event Canceled(
    address _owner,
    string _id,
    string _name,
    uint256 _value 
  );

  function Renthereum() {
    itemsCount = 0;
  }

  modifier isValidItem(uint256 _index, mapping(uint256 => Order) _itemsForHire) {
    require(_index >= 0 && _index < itemsCount && _itemsForHire[_index].status == Status.AVAILABLE);
    _;
  }

  modifier isValidValue(uint _hirePeriod, uint256 _itemValue) {
    require(msg.value == _itemValue * _hirePeriod);
    _;
  }

  modifier isValidPeriod(uint _hirePeriod, uint _minPeriod, uint _maxPeriod){
    require(_hirePeriod >= _minPeriod && _hirePeriod <= _maxPeriod);
    _;
  }

  modifier onlyOwner(address _itemOwner) {
    require(msg.sender == _itemOwner);
    _;
  }

  function hire(uint256 _index, uint _period) payable
    isValidItem(_index, itemsForHire)
    isValidValue(_period, itemsForHire[_index].dailyValue) 
    isValidPeriod(_period, itemsForHire[_index].minPeriod, itemsForHire[_index].maxPeriod)
    public
    returns(bool)
  {
    Order item = itemsForHire[_index];  
    item.owner.transfer(msg.value);
    item.customer = msg.sender;
    item.hirePeriod = _period;
    item.status = Status.RENTED;
    itemsForHire[_index] = item;
    Rented(item.owner, msg.sender, _period, msg.value);
    return true;
  }

  function createOrder(
    string _id,
    string _name,
    string _description,
    uint256 _dailyValue,
    uint _minPeriod,
    uint _maxPeriod)
    public
    returns(uint) 
  {
    Order memory item;
    item.owner = msg.sender;
    item.id = _id;
    item.name = _name;
    item.description = _description;
    item.dailyValue = _dailyValue;
    item.minPeriod = _minPeriod;
    item.maxPeriod = _maxPeriod;
    itemsForHire[itemsCount] = item;
    itemsCount++;
    Ordered(_id, item.owner, item.name, item.dailyValue);
    return itemsCount - 1;
  }

  function cancelOrder(uint256 _index)
    isValidItem(_index, itemsForHire)
    onlyOwner(itemsForHire[_index].owner)
    returns(bool)
  {
    Order memory order = itemsForHire[_index];
    order.status = Status.CANCELED;
    itemsForHire[_index] = order;
    Canceled(order.owner,order.id, order.name, order.dailyValue);  
    return true;
  }

}
