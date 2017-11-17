/** @file */
#ifndef __DEQUE_H
#define __DEQUE_H

#include "ElementNotExist.h"
#include "IndexOutOfBound.h"

/**
 * An deque is a linear collection that supports element insertion and removal at both ends.
 * The name deque is short for "double ended queue" and is usually pronounced "deck".
 * Remember: all functions but "contains" and "clear" should be finished in O(1) time.
 *
 * You need to implement both iterators in proper sequential order and ones in reverse sequential order.
 */
template <class elemType>
class Deque
{
public:
	elemType **a;
	int head, tail, currentLength, totalSize;

	elemType **newMemory(int length) {
		elemType **tmp = new elemType*[length];
		for (int i = 0; i < length; ++ i)
			tmp[i] = NULL;
		return tmp;
	}

	void moreMemory() {
		if (currentLength >= totalSize - 1) {
			elemType **tmp = newMemory(totalSize * 2 + 1);
			for (int i = 0; i < currentLength; ++ i)
				tmp[i] = a[(head + i) % totalSize];
            totalSize = totalSize * 2 + 1;
			delete [] a;
			a = tmp;
			head = 0; tail = currentLength - 1;
			if (tail < 0) tail = totalSize - 1;
		}
	}

public:
    class Iterator
    {
	private:
		int current;
		bool flag, pre;
		Deque<elemType> *now;
    public:
		Iterator(Deque<elemType> *c, bool flag) : now(c), flag(flag), current(0), pre(false) {}
        /**
         * TODO Returns true if the iteration has more elements.
         */
        bool hasNext() {
			return current < now->currentLength;
		}

        /**
         * TODO Returns the next element in the iteration.
         * @throw ElementNotExist exception when hasNext() == false
         */
        const elemType &next() {
			if (!hasNext()) throw ElementNotExist("Iterator next");
			pre = true;
			++ current;
			if (flag) return *now->a[(now->head + current - 1) % now->totalSize];
			else return *now->a[(now->tail + now->totalSize - current + 1) % now->totalSize];
		}

        /**
         * TODO Removes from the underlying collection the last element
         * returned by the iterator
         * The behavior of an iterator is unspecified if the underlying
         * collection is modified while the iteration is in progress in
         * any way other than by calling this method.
         * @throw ElementNotExist
         */
        void remove() {
			if (pre) {
				pre = false;
				-- current;
				if (flag) {
					delete now->a[(now->head + current) % now->totalSize];
					for (int i = (now->head + current) % now->totalSize; i != now->tail; i = (i + 1) % now->totalSize)
						now->a[i] = now->a[(i + 1) % now->totalSize];
					now->a[now->tail] = NULL;
					now->tail = (now->tail + now->totalSize - 1) % now->totalSize;
				} else {
					delete now->a[(now->tail + now->totalSize - current) % now->totalSize];
					for (int i = (now->tail + now->totalSize - current) % now->totalSize; i != now->head; i = (i + now->totalSize - 1) % now->totalSize)
						now->a[i] = now->a[(i + now->totalSize - 1) % now->totalSize];
					now->a[now->head] = NULL;
					now->head = (now->head + 1) % now->totalSize;
				}
				-- now->currentLength;;
			} else throw ElementNotExist("Iterator remove");
		}
    };

    /**
     * TODO Constructs an empty deque.
     */
    Deque() {
		currentLength = totalSize = 0;
		head = tail = 0;
		a = NULL;
	}

    /**
     * TODO Destructor
     */
    ~Deque() {clear(); if(a) delete [] a;}

    /**
     * TODO Assignment operator
     */
    Deque& operator=(const Deque &x) {
		clear();
		if (!x.isEmpty()) {
			a = newMemory(totalSize = x.totalSize);
			for (int i = 0; i < x.currentLength; ++ i)
				a[i] = new elemType(*x.a[(x.head + i) % x.totalSize]);
			head = 0;
			tail = x.currentLength - 1;
			currentLength = x.currentLength;
			return *this;
		}
	}

    /**
     * TODO Copy-constructor
     */
    Deque(const Deque& x) {
		currentLength = totalSize = 0;
		head = tail = 0;
		a = NULL;
		if (!x.isEmpty()) {
			a = newMemory(totalSize = x.totalSize);
			for (int i = 0; i < x.currentLength; ++ i)
				a[i] = new elemType(*x.a[(x.head + i) % x.totalSize]);
			head = 0;
			tail = x.currentLength - 1;
			currentLength = x.currentLength;
		}
	}
	/**
	 * TODO Inserts the specified element at the front of this deque.
	 */
	void addFirst(const elemType &element) {
		moreMemory();
		head = (head + totalSize - 1) % totalSize;
		a[head] = new elemType(element);
		++ currentLength;
	}

	/**
	 * TODO Inserts the specified element at the end of this deque.
	 */
	void addLast(const elemType &element) {
		moreMemory();
		tail = (tail + 1) % totalSize;
		a[tail] = new elemType(element);
		++ currentLength;;
	}

	/**
	 * TODO Returns true if this deque contains the specified element.
	 */
	bool contains(const elemType &element) const {
		if (isEmpty()) return false;
		int i = head;
		if (*a[i] == element) return true;
		while (i != tail) {
			i = (i + 1) % totalSize;
			if (*a[i] == element) return true;
		}
		return false;
	}

	/**
	 * TODO Removes all of the elements from this deque.
	 */
	 void clear() {
		if (!isEmpty()) {
            for (int i = head; i != tail; i = (i + 1) % totalSize)
                delete a[i];
            delete a[tail];
			delete [] a;
		}
		currentLength = totalSize = 0;
		head = tail = 0;
		a = NULL;
	 }

	 /**
	  * TODO Returns true if this deque contains no elements.
	  */
	bool isEmpty() const {return !currentLength;}

	/**
	 * TODO Retrieves, but does not remove, the first element of this deque.
	 * @throw ElementNotExist
	 */
	 const elemType& getFirst() {
		if (isEmpty()) throw ElementNotExist("getFirst");
		return *a[head];
	 }

	 /**
	  * TODO Retrieves, but does not remove, the last element of this deque.
	  * @throw ElementNotExist
	  */
	 const elemType& getLast() {
		if (isEmpty()) throw ElementNotExist("getLast");
		return *a[tail];
	}

	 /**
	  * TODO Removes the first element of this deque.
	  * @throw ElementNotExist
	  */
	void removeFirst() {
		if (isEmpty()) throw ElementNotExist("removeFirst");
		delete a[head];
		head = (head + 1) % totalSize;
		-- currentLength;
	}

	/**
	 * TODO Removes the last element of this deque.
	 * @throw ElementNotExist
	 */
	void removeLast() {
		if (isEmpty()) throw ElementNotExist("removeLast");
		delete a[tail];
		tail = (tail + totalSize - 1) % totalSize;
		-- currentLength;
	}

	/**
	 * TODO Returns a const reference to the element at the specified position in this deque.
	 * The index is zero-based, with range [0, size).
	 * @throw IndexOutOfBound
	 */
	const elemType& get(int index) const {
		if (index < 0 || index >= currentLength)
			throw IndexOutOfBound("get");
		return *a[(head + index) % totalSize];
	}

	/**
	 * TODO Replaces the element at the specified position in this deque with the specified element.
	 * The index is zero-based, with range [0, size).
	 * @throw IndexOutOfBound
	 */
	void set(int index, const elemType &element) {
		if (index < 0 || index >= currentLength)
			throw IndexOutOfBound("set");
		*a[(head + index) % totalSize] = element;
	}

	/**
	 * TODO Returns the number of elements in this deque.
	 */
	int size() const {return currentLength;}

	/**
	 * TODO Returns an iterator over the elements in this deque in proper sequence.
	 */
	Iterator iterator() {
		return Iterator(this, true);
	}

	/**
	 * TODO Returns an iterator over the elements in this deque in reverse sequential order.
	 */
	Iterator descendingIterator() {
		return Iterator(this, false);
	}
};

#endif
