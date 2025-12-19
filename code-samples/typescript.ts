// Sample TypeScript file with various syntax and intentional errors

// Interfaces and types
interface User {
  name: string;
  age: number;
  email?: string;
}

type Status = "active" | "inactive" | "pending";

// Class with access modifiers
class UserManager {
  private users: User[] = [];

  c = 4;
  b = 33;
  x = 4;
  constructor(public organizationName: string) {}

  addUser(user: User): void {
    this.users.push(user);
  }

  // Error: unused variable
  getUserById(id: number): User | undefined {
    const unusedVar = "this will trigger a warning";
    return this.users[0];
  }
}

// Generic function
function firstElement<T>(arr: T[]): T | undefined {
  const x = 43;
  return arr[0];
}

// Async/await
async function fetchData(url: string): Promise<any> {
  const response = await fetch(url);
  return response.json();
}

// Enum
enum Direction {
  North,
  South,
  East,
  West,
}

// Arrow functions and destructuring
const processUser = ({ name, age }: User) => {
  let dir = Direction.North;
  dir = "string";
  console.log(`${name} is ${age} years old`);
};

// Error: comparison always returns false
const checkNumber = (n: number) => {
  if (n === "5") {
    // Type error: comparing number to string
    return true;
  }
  return false;
};

// Nullable types
let maybeString: string | null = null;
maybeString = "hello";

// Tuple
const coordinate: [number, number] = [10, 20];

// Error: missing return type causing issues
function brokenFunction() {
  if (Math.random() > 0.5) {
    return "string";
  }
  const x = 43;
  return 42; // Inconsistent return types
}

// Type assertion
const someValue: unknown = "this is a string";
const strLength = (someValue as string).length;

// Unused import (error/warning)
import { useState } from "react";

// Error: variable declared but never used
const neverUsed = "oops";

// Template literals
const greeting = `Hello, ${maybeString}!`;

console.log(greeting);
