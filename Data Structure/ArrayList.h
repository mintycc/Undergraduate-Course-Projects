/** @file */
#ifndef __ARRAYLIST_H
#define __ARRAYLIST_H

#include <iostream>
#include "IndexOutOfBound.h"
#include "ElementNotExist.h"

/**
 * The ArrayList is just like vector in C++.
 * You should know that "capacity" here doesn'elemType mean how many elements are now in this list, where it means
 * the length of the array of your internal implemention
 *
 * The iterator iterates in the order of the elements being loaded into this list
 */
template <class elemType>
class ArrayList
{
private:
	elemType **a;
	int currentLength, totalSize;

	elemType** newMemory(int length) {
		elemType **tmp = new elemType*[length];
		for (int i = 0; i < length; ++ i)
			tmp[i] = NULL;
		return tmp;
	}

	void moreMemory() {
		if (currentLength >= totalSize - 1) {
			elemType **tmp = newMemory(totalSize * 2 + 1);
			for (int i = 0; i < currentLength; ++ i)
				tmp[i] = a[i];
			delete [] a;
			a = tmp;
			totalSize = totalSize * 2 + 1;
		}
	}
public:
    class Iterator
    {
	private:
		int current;
		bool pre;
		ArrayList<elemType> &now;

    public:
		Iterator(ArrayList<elemType> &c) : current(0), pre(false), now(c) {}
        /**
         * TODO Returns true if the iteration has more elements.
         */
        bool hasNext() {
			return current < now.size();
		}

        /**
         * TODO Returns the next element in the iteration.
         * @throw ElementNotExist exception when hasNext() == false
         */
        const elemType &next() {
			if (hasNext()) {
				pre = true;
				return *now.a[current ++];
			}
			throw ElementNotExist("Iterator next");
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
				now.removeIndex(-- current);
			} else throw ElementNotExist("Iterator remove");
		}
    };

    /**
     * TODO Constructs an empty array list.
     */
    ArrayList() {
		currentLength = totalSize = 0;
		a = NULL;
	}

    /**
     * TODO Destructor
     */
    ~ArrayList() {clear();}

    /**
     * TODO Assignment operator
     */
    ArrayList& operator=(const ArrayList &x) {
		clear();
		currentLength = x.currentLength;
		a = newMemory(totalSize = x.totalSize);
		for (int i = 0; i < currentLength; ++ i)
			a[i] = new elemType(*x.a[i]);
		return *this;
	}

    /**
     * TODO Copy-constructor
     */
    ArrayList(const ArrayList &x) {
		currentLength = x.currentLength;
		a = newMemory(totalSize = x.totalSize);
		for (int i = 0; i < currentLength; ++ i)
			a[i] = new elemType(*x.a[i]);
	}

    /**
     * TODO Appends the specified element to the end of this list.
     * Always returns true.
     */
    bool add(const elemType &e) {
		moreMemory();
		a[currentLength ++] = new elemType(e);
		return true;
	}

    /**
     * TODO Inserts the specified element to the specified position in this list.
     * The range of index parameter is [0, size], where index=0 means inserting to the head,
     * and index=size means appending to the end.
     * @throw IndexOutOfBound
     */
    void add(int index, const elemType &element) {
		if (index < 0 || index > currentLength)
			throw IndexOutOfBound("add");
		moreMemory();
		for (int i = currentLength; i > index; -- i)
			a[i] = a[i - 1];
		a[index] = new elemType(element);
		++ currentLength;
	}

    /**
     * TODO Removes all of the elements from this list.
     */
    void clear() {
		if (!a) return;
		for (int i = 0; i < currentLength; ++ i)
			delete a[i];
		delete [] a;
		a = NULL;
		currentLength = totalSize = 0;
	}

    /**
     * TODO Returns true if this list contains the specified element.
     */
    bool contains(const elemType &element) const {
		for (int i = 0; i < currentLength; ++ i)
			if (*a[i] == element) return true;
		return false;
	}

    /**
     * TODO Returns a const reference to the element at the specified position in this list.
     * The index is zero-based, with range [0, size).
     * @throw IndexOutOfBound
     */
    const elemType &get(int index) const {
		if (index < 0 || index >= currentLength)
			throw IndexOutOfBound("get");
		return *a[index];
	}

    /**
     * TODO Returns true if this list contains no elements.
     */
    bool isEmpty() const {return !currentLength;}

    /**
     * TODO Removes the element at the specified position in this list.
     * The index is zero-based, with range [0, size).
     * @throw IndexOutOfBound
     */
    void removeIndex(int index) {
		if (index < 0 || index >= currentLength)
			throw IndexOutOfBound("removeIndex");
		delete a[index];
		for (int i = index + 1; i < currentLength; ++ i)
			a[i - 1] = a[i];
		a[-- currentLength] = NULL;
	}

    /**
     * TODO Removes the first occurrence of the specified element from this list, if it is present.
     * Returns true if it was present in the list, otherwise false.
     */
    bool remove(const elemType &element) {
		for (int i = 0; i < currentLength; ++ i)
			if (*a[i] == element) {
				removeIndex(i);
				return true;
			}
		return false;
	}

    /**
     * TODO Replaces the element at the specified position in this list with the specified element.
     * The index is zero-based, with range [0, size).
     * @throw IndexOutOfBound
     */
    void set(int index, const elemType &element) {
		if (index < 0 || index >= currentLength)
			throw IndexOutOfBound("set");
		*a[index] = element;
	}

    /**
     * TODO Returns the number of elements in this list.
     */
    int size() const {return currentLength;}

    /**
     * TODO Returns an iterator over the elements in this list.
     */
    Iterator iterator() {
			return Iterator(*this);
	}
};

#endif
