package generic

import "sync"

// LockedSet provides a thread-safe set implementation
type LockedSet[T comparable] struct {
	_map  map[T]struct{} // Quick and dirty solution built on go's map builtin
	mutex sync.Mutex
}

func (self *LockedSet[T]) Insert(element T) {
	self.mutex.Lock()
	defer self.mutex.Unlock()
	self._map[element] = struct{}{}
}

func (self *LockedSet[T]) Remove(element T) {
	self.mutex.Lock()
	defer self.mutex.Unlock()
	delete(self._map, element)
}

func (self *LockedSet[T]) ForEach(lambda func(T)) {
	self.mutex.Lock()
	defer self.mutex.Unlock()
	for element, _ := range self._map {
		lambda(element)
	}
}

func NewLockedSet[T comparable]() LockedSet[T] {
	return LockedSet[T]{
		_map:  make(map[T]struct{}),
		mutex: sync.Mutex{},
	}
}
