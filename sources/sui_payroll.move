module sui_payroll::sui_payroll {
    use sui::transfer;
    use sui::sui::SUI;
    use std::string::String;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use sui::table::{Self, Table};

    // Errors
    const EInsufficientBalance: u64 = 1;
    const ENotOrganization: u64 = 2;
    const ENotEmployee: u64 = 4;

    // Structs
    struct Organization has key, store {
        id: UID,
        name: String,
        email: String,
        balance: Balance<SUI>,
        employees: Table<ID, Employee>,
        new_payrolls: Table<ID, Payroll>,
        paid_payrolls: Table<ID, Payroll>,
        principal: address,
    }

    struct OrganizationCap has key {
        id: UID,
        for: ID,
    }

    struct Employee has key, store {
        id: UID,
        name: String,
        home: String,
        principal: address,
        balance: Balance<SUI>,
        department: String,
        designation: String,
        hireDate: String,
    }

    struct Payroll has key, store {
        id: UID,
        employee: address,
        date: String,
        month: String,
        year: String,
        basicSalary: u64,
        allowances: u64,
        netSalary: u64,
    }

    public fun add_organization_info(
        name: String,
        email: String,
        ctx: &mut TxContext
    ) : OrganizationCap {
        let id = object::new(ctx);
        let inner = object::uid_to_inner(&id);
        let organization = Organization {
            id,
            name,
            email,
            balance: balance::zero<SUI>(),
            principal: tx_context::sender(ctx),
            employees: table::new<ID, Employee>(ctx),
            new_payrolls: table::new<ID, Payroll>(ctx),
            paid_payrolls: table::new<ID, Payroll>(ctx),
        };
        transfer::share_object(organization);

        OrganizationCap {
            id: object::new(ctx),
            for: inner,
        }
    }

    // deposit
    public fun deposit(
        organization: &mut Organization,
        amount: Coin<SUI>,
    ) {
        let coin = coin::into_balance(amount);
        balance::join(&mut organization.balance, coin);
    }

    // withdraw
    public fun withdraw_organization_balance(
        cap: &OrganizationCap,
        organization: &mut Organization,
        amount: u64,
        ctx: &mut TxContext
    ) : Coin<SUI> {
        assert!(cap.for == object::id(organization), ENotOrganization);
        let payment = coin::take(&mut organization.balance, amount, ctx);
        payment
    }

    public fun add_employee_info(
        name: String,
        home: String,
        department: String,
        designation: String,
        hireDate: String,
        ctx: &mut TxContext
    ) : Employee {
        let id = object::new(ctx);
        Employee {
            id,
            name,
            home,
            principal: tx_context::sender(ctx),
            balance: balance::zero<SUI>(),
            department,
            designation,
            hireDate,
        }
    }

    //   employee withdraw
    public fun withdraw_employee_balance(
        employee: &mut Employee,
        amount: u64,
        ctx: &mut TxContext
    ) : Coin<SUI> {
        assert!(employee.principal == tx_context::sender(ctx), ENotEmployee);
        let payment = coin::take(&mut employee.balance, amount, ctx);
        payment
    }

    public fun add_payroll_info(
        organization: &mut Organization,
        employee: &mut Employee,
        date: String,
        month: String,
        year: String,
        basicSalary: u64,
        allowances: u64,
        netSalary: u64,
        ctx: &mut TxContext
    ) {
        let id = object::new(ctx);
        let payroll = Payroll {
            id,
            employee: employee.principal,
            date,
            month,
            year,
            basicSalary,
            allowances,
            netSalary,
        };

        let total = basicSalary + allowances;
        assert!(balance::value(&organization.balance) >= total, EInsufficientBalance);
        let payment = coin::take(&mut organization.balance, total, ctx);
        coin::put(&mut employee.balance, payment);

        table::add<ID, Payroll>(&mut organization.new_payrolls, object::uid_to_inner(&payroll.id), payroll);
    }

    public fun remove_payroll_info(
        organization: &mut Organization,
        payroll: ID,
    ) {
        let payroll = table::remove(&mut organization.new_payrolls, payroll);
        let Payroll {
            id,
            employee: _,
            date: _,
            month: _,
            year: _,
            basicSalary: _,
            allowances: _,
            netSalary: _,
        } = payroll;
        object::delete(id);
    }
}