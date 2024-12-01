const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    // Create a new user
    const newUser = await prisma.user.create({
        data: {
            firstName: 'John',
            lastName: 'Doe',
            email: 'john.doe@example.com',
        },
    });
    console.log('New User:', newUser);

    // Fetch all users
    const users = await prisma.user.findMany();
    console.log('All Users:', users);
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
