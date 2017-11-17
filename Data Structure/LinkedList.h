/** @file */
#ifndef __LINKEDLIST_H
#define __LINKEDLIST_H

#include <iostream>
using namespace std;
#include "IndexOutOfBound.h"
#include "ElementNotExist.h"

/**
 * A linked list.
 *
 * The iterator iterates in the order of the elements being loaded into this list.
 */
template <class elemType>
class LinkedList
{
private:
	struct Node {
		elemType data;
		Node *pre, *next;

		Node(const elemType &x, Node *p = NULL, Node *n = NULL) {
			data = x; pre = p; next = n;
		}
		Node() : pre(NULL), next(NULL) {};
		~Node() {};
	};

	Node *head, *tail;
	int currentLength;

	Node *move(int i) {
		Node *p = head;
		while (i --) p = p->next;
		return p;
	}

public:
    class Iterator
	{
	private:
		Node *current;
		bool pre;
		LinkedList<elemType> &now;

    public:
		Iterator(LinkedList<elemType> &p) : pre(false), now(p), current(p.head){}
        /**
         * TODO Returns true if the iteration has more elements.
         */
        bool hasNext() {return current->next != now.tail;}

        /**
         * TODO Returns the next element in the iteration.
         * @throw ElementNotExist exception when hasNext() == false
         */
        const elemType &next() {
			if (!hasNext()) throw ElementNotExist("Iterator next");
			pre = true;
			current = current->next;
			return current->data;
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
			if (!pre) throw ElementNotExist("Iterator remove");
			pre = false;
			-- now.currentLength;
			current->pre->next = current->next;
			current->next->pre = current->pre;
			Node *tmp = current->pre;
			delete current;
			current = tmp;
		}
    };

    /**
     * TODO Constructs an empty linked list
     */
    LinkedList() {
		head = new Node();
		head->next = tail = new Node();
		tail->pre = head;
		currentLength = 0;
	}

    /**
     * TODO Copy constructor
     */
    LinkedList(const LinkedList<elemType> &c) {
		head = new Node();
		head->next = tail = new Node();
		tail->pre = head;
		currentLength = 0;
		for (Node *p = c.head->next; p != c.tail; p = p->next)
			addLast(p->data);
	}

    /**
     * TODO Assignment operator
     */
    LinkedList<elemType>& operator=(const LinkedList<elemType> &c) {
		if (head == c.head) return *this;
		clear();
		for (Node *p = c.head->next; p != c.tail; p = p->next)
			addLast(p->data);
		return *this;
	}

    /**
     * TODO Desturctor
     */
    ~LinkedList() {
		clear(); delete head; delete tail;
	}

    /**
     * TODO Appends the specified element to the end of this list.
     * Always returns true.
     */
    bool add(const elemType &elem) {
		Node *tmp = new Node(elem, tail->pre, tail);
		tmp->pre->next = tmp;
		tail->pre = tmp;
		++ currentLength;
		return true;
	}

    /**
     * TODO Inserts the specified element to the beginning of this list.
     */
    void addFirst(const elemType &elem) {
		Node *tmp = new Node(elem, head, head->next);
		head->next = tmp;
		tmp->next->pre = tmp;
		++ currentLength;
	}

    /**
     * TODO Insert the specified element to the end of this list.
     * Equivalent to add.
     */
    void addLast(const elemType &elem) {add(elem);}

    /**
     * TODO Inserts the specified element to the specified position in this list.
     * The range of index parameter is [0, size], where index=0 means inserting to the head,
     * and index=size means appending to the end.
     * @throw IndexOutOfBound
     */
    void add(int index, const elemType& elem) {
		if (index < 0 || index > currentLength)
			throw IndexOutOfBound("add");
		Node *pos = move(index);
		Node *tmp = new Node(elem, pos, pos->next);
		tmp->pre->next = tmp;
		tmp->next->pre = tmp;
		++currentLength;
	}

    /**
     * TODO Removes all of the elements from this list.
     */
    void clear() {
		Node *p = head->next, *q;
		while (p != tail) {
			q = p->next;
			delete p;
			p = q;
		}
		head->next = tail;
		tail->pre = head;
		currentLength = 0;
	}

    /**
     * TODO Returns true if this list contains the specified element.
     */
    bool contains(const elemType& elem) const {
		Node *tmp = head->next;
		while (tmp != tail) {
			if (tmp->data == elem)
				return true;
			tmp = tmp->next;
		}
		return false;
	}

    /**
     * TODO Returns a const reference to the element at the specified position in this list.
     * The index is zero-based, with range [0, size).
     * @throw IndexOutOfBound
     */
    const elemType& get(int index) const {
		if (index < 0 || index >= currentLength)
			throw IndexOutOfBound("get");
		Node *tmp = head;
		++ index;
		while (index --) tmp = tmp->next;
		return tmp->data;
	}

    /**
     * TODO Returns a const reference to the first element.
     * @throw ElementNotExist
     */
    const elemType& getFirst() const {
		if (isEmpty()) throw ElementNotExist("getFirst");
		return head->next->data;
	}

    /**
     * TODO Returns a const reference to the last element.
     * @throw ElementNotExist
     */
    const elemType& getLast() const {
		if (isEmpty()) throw ElementNotExist("getLast");
		return tail->pre->data;
	}

    /**
     * TODO Returns true if this list contains no elements.
     */
    bool isEmpty() const {
		if (!currentLength) return true;
		return false;
	}

    /**
     * TODO Removes the element at the specified position in this list.
     * The index is zero-based, with range [0, size).
     * @throw IndexOutOfBound
     */
    void removeIndex(int index) {
		if (index < 0 || index >= currentLength)
			throw IndexOutOfBound("removeIndex");
		Node *tmp = move(index + 1);
		tmp->pre->next = tmp->next;
		tmp->next->pre = tmp->pre;
		delete tmp;
		-- currentLength;
	}

    /**
     * TODO Removes the first occurrence of the specified element from this list, if it is present.
     * Returns true if it was present in the list, otherwise false.
     */
    bool remove(const elemType &elem) {
		for (Node *p = head->next; p != tail; p = p->next)
			if (p->data == elem) {
				p->pre->next = p->next;
				p->next->pre = p->pre;
				delete p;
				-- currentLength;
				return true;
			}
		return false;
	}

    /**
     * TODO Removes the first element from this list.
     * @throw ElementNotExist
     */
    void removeFirst() {
		if (isEmpty()) throw ElementNotExist("removeFirst");
		Node *tmp = head->next;
		head->next = tmp->next;
		tmp->next->pre = head;
		delete tmp;
		-- currentLength;
	}

    /**
     * TODO Removes the last element from this list.
     * @throw ElementNotExist
     */
    void removeLast() {
		if (isEmpty()) throw ElementNotExist("removeLast");
		Node *tmp = tail->pre;
		tail->pre = tmp->pre;
		tmp->pre->next = tail;
		delete tmp;
		-- currentLength;
	}

    /**
     * TODO Replaces the element at the specified position in this list with the specified element.
     * The index is zero-based, with range [0, size).
     * @throw IndexOutOfBound
     */
    void set(int index, const elemType &elem) {
		if (index < 0 || index >= currentLength)
			throw IndexOutOfBound("set");
		Node *tmp = move(index + 1);
		tmp->data = elem;
	}

    /**
     * TODO Returns the number of elements in this list.
     */
    int size() const {return currentLength;}

    /**
     * TODO Returns an iterator over the elements in this list.
     */
    Iterator iterator() {return Iterator(*this);}
};

#endif
