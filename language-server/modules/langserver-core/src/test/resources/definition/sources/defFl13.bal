
public type Person record {
    string name = "";
    int age = 0;
};

public type Employee record {
    string name = "";
    int age = 0;
    int empNo = 0;
};

public Person person = {};

public Employee employee = {
    empNo: 100
};

(Employee, Person) pp = (employee, person);