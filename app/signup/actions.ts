"use server"

import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";
import bcrypt from "bcryptjs";


const MIN_PASSWORD_LENGHT = 8;
const EMAIL_REGEX = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$/;

function isValidEmail(email: string): boolean {
  return EMAIL_REGEX.test(email);
}


export type SignupState = { error?: string }

export async function signupAction(
    _prevState: SignupState | null,
    formData: FormData
): Promise<SignupState> {
    const name = formData.get("name") as string | undefined;
    const email = formData.get("email") as string | undefined;
    const password = formData.get("password") as string | undefined;

    if(!email) {
        return { error: "Введите email"}
    }

    if(!EMAIL_REGEX.test(email)) {
        return { error: "Некрорректный формат email" }
    }

    if(!password || password.length < MIN_PASSWORD_LENGHT) {
        return { error: "Пароль должен быть 8 символов." }
    }

    const existing = await prisma.user.findUnique({
        where: { email }
    })

    if ( existing ) {
        return { error: "Email уже занят."}
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    await prisma.user.create({
        data: {
            email, 
            name,
            password: hashedPassword
        }
    })
    redirect("/login");
}